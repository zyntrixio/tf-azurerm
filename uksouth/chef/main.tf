terraform {
  backend "azurerm" {
    storage_account_name = "binkitops"
    container_name = "terraform"
    key = "uksouth-chef.tfstate"
  }
}

provider "azurerm" {
  version = "~> 1.37.0"
  subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
  client_id = "98e2ee67-a52d-40fc-9b39-155887530a7b"
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
}

resource "azurerm_resource_group" "rg" {
  name = "${var.location}-chef"
  location = var.location

  tags = {
    environment = "production"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name = "${var.environment}-vnet"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["192.168.5.0/24"]

  tags = {
    environment = "production"
  }
}

resource "azurerm_subnet" "subnet" {
  count = length(var.subnet_address_prefixes)
  name = format("subnet-%02d", count.index + 1)
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix = element(var.subnet_address_prefixes, count.index)
  lifecycle {
    ignore_changes = [
      network_security_group_id,
      route_table_id
    ]
  }
}

resource "azurerm_network_security_group" "nsg" {
  count = length(var.subnet_address_prefixes)
  name = format("${var.environment}-subnet-%02d-nsg", count.index + 1)
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  count = length(var.subnet_address_prefixes)
  subnet_id = element(azurerm_subnet.subnet.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.nsg.*.id, count.index)
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
  count = length(var.subnet_address_prefixes)
  subnet_id      = element(azurerm_subnet.subnet.*.id, count.index)
  route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_route_table" "rt" {
  name = "${var.environment}-routes"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true

  route {
    name = "firewall"
    address_prefix = "0.0.0.0/0"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.4"
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_virtual_network_peering" "peer" {
  name = "local-to-firewall"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-firewall/providers/Microsoft.Network/virtualNetworks/firewall-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_lb" "lb" {
  name = "${var.environment}-lb"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name = "subnet-01"
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.subnet_address_prefixes[0], 4)
    subnet_id = azurerm_subnet.subnet.0.id
  }
  tags = {
    environment = "production"
  }
}

resource "azurerm_lb_backend_address_pool" "pools" {
  count = length(var.subnet_address_prefixes)
  name = format("subnet-%02d", count.index + 1)
  loadbalancer_id = azurerm_lb.lb.id
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "chef" {
  name = "chef-01-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_accelerated_networking = false
  depends_on = [azurerm_lb.lb]

  ip_configuration {
    name = "primary"
    subnet_id = azurerm_subnet.subnet.0.id
    private_ip_address_allocation = "Dynamic"
    primary = true
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "chef-bap-assoc" {
  network_interface_id = azurerm_network_interface.chef.id
  ip_configuration_name = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools.0.id
}

module "chef_lb_rules" {
  source = "../../modules/lb_rules"
  loadbalancer_id = azurerm_lb.lb.id
  backend_id = azurerm_lb_backend_address_pool.pools.0.id
  resource_group_name = azurerm_resource_group.rg.name
  frontend_ip_configuration_name = "subnet-01"

  lb_port = {
    chef_api = [ "4444", "TCP", "4444" ]
  }
}

resource "azurerm_virtual_machine" "chef" {
  name = "chef-01"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.chef.id]

  vm_size = "Standard_B2ms"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = false

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name = "chef-01-disk"
    disk_size_gb = "32"
    caching = "ReadOnly"
    create_option = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name = "chef-01"
    admin_username = "terraform"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/terraform/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrdSta+Sv3YWupzHk4U1VS7jvUvkQgmWexanDnGHLx7YjBKxi1tuhE0WgzgkbB3WqDNLrj5dXdv9la8S9VvrL1L1r4YG+5N0f6Ri1xE+cGei6aFAm57eLPnGhAY6lxiPSx79x+cfmW0YdZHI/6rb4Gix+KoH4BOPZnshxjoyL5MJpel2/5LZHWuazT3ihzWXemhMQ11mXJGot+tuVRB3tkVg+vi//YyRo5vKQSjpvirrP8MgQY76jk0RzxhwsP1d+7lkeAcedPilNpmhP72rfWMTxkrbO7XQrZMpIeL7qywdaOb0tPEB0n9KscUwiMvM4oOLVizsgzKoUOZ91rkxhb id_bink_azure_terraform"
    }
  }

  tags = {
    environment = "production"
  }
}

module "worker_nsg_rules" {
  source = "../../modules/nsg_rules"
  network_security_group_name = "${var.environment}-subnet-01-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  rules = [
    {
      name = "BlockEverything"
      priority = "4096"
      access = "Deny"
    },
    {
      name = "AllowLoadBalancer"
      source_address_prefix = "AzureLoadBalancer"
      priority = "4095"
    },
    {
      name = "AllowSSH"
      priority = "500"
      protocol = "TCP"
      destination_port_range = "22"
      destination_address_prefix = var.subnet_address_prefixes[0]
      source_address_prefix = "192.168.4.0/24"
    },
    {
      name = "AllowHttpsTraffic"
      priority = "100"
      destination_port_range = "4444"
      protocol = "TCP"
      destination_address_prefix = var.subnet_address_prefixes[0]
    }
  ]
}