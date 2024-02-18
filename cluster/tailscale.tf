resource "azurerm_public_ip" "tailscale" {
  name                = "${azurerm_resource_group.i.name}-tailscale"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "tailscale" {
  name                = "${azurerm_resource_group.i.name}-tailscale"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tailscale.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tailscale.id
  }
}

resource "azurerm_network_security_group" "tailscale" {
  name                = "${azurerm_resource_group.i.name}-tailscale"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name

  security_rule {
    name                       = "BlockEverything"
    description                = "Default Block All Rule"
    access                     = "Deny"
    priority                   = 4096
    direction                  = "Inbound"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                         = "tailscale"
    priority                     = 100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Udp"
    source_port_range            = "*"
    destination_port_range       = "41641"
    source_address_prefix        = "*"
    destination_address_prefixes = [azurerm_public_ip.tailscale.ip_address]
  }
}

resource "azurerm_network_interface_security_group_association" "tailscale" {
  network_interface_id      = azurerm_network_interface.tailscale.id
  network_security_group_id = azurerm_network_security_group.tailscale.id
}

data "cloudinit_config" "tailscale" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
    #cloud-config
    write_files:
      - path: /etc/sysctl.d/99-tailscale.conf
        content: |
          net.ipv4.ip_forward = 1
          net.ipv6.conf.all.forwarding = 1
    runcmd:
      - ["sh", "-c", "curl -fsSL https://tailscale.com/install.sh | sh"]
      - ["sysctl", "-p", "/etc/sysctl.d/99-tailscale.conf"]
      - ["tailscale", "up", "--authkey=${var.tailscale.client_secret}", "--advertise-tags=tag:terraform"]
      - ["tailscale", "set", "--ssh"]
      - ["tailscale", "set", "--accept-dns=false"]
      - ["tailscale", "set", "--advertise-routes=${one(azurerm_subnet.cloudamqp.address_prefixes)},${one(azurerm_subnet.grafana.address_prefixes)},${one(azurerm_subnet.postgres.address_prefixes)},${one(azurerm_subnet.redis.address_prefixes)},${one(azurerm_subnet.kube_controller.address_prefixes)},${cidrhost(cidrsubnet(var.common.cidr, 1, 0), 32766)}/32"]
    EOF
  }
}

resource "azurerm_linux_virtual_machine" "tailscale" {
  name                  = "${azurerm_resource_group.i.name}-tailscale"
  resource_group_name   = azurerm_resource_group.i.name
  location              = azurerm_resource_group.i.location
  size                  = "Standard_D2ads_v5"
  admin_username        = "tailscale"
  network_interface_ids = [azurerm_network_interface.tailscale.id]
  custom_data           = data.cloudinit_config.tailscale.rendered

  admin_ssh_key {
    username   = "tailscale"
    public_key = file("ssh.pub")
  }

  os_disk {
    disk_size_gb         = 32
    caching              = "ReadOnly"
    storage_account_type = "Premium_ZRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12-gen2"
    version   = "latest"
  }
}
