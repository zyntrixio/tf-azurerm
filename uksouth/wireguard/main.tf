terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 1.3.2"
}

variable "common" {
  type = object({
    firewall = object({
      resource_group = string
      ip_address     = string
      vnet_name      = string
      vnet_id        = string
    })
    private_dns = object({
      resource_group  = string
      primary_zone    = string
      secondary_zones = list(string)
    })
    location = optional(string, "uksouth")
    vm_size  = optional(string, "Standard_D2as_v5")
    tags = optional(map(string), {
      Environment = "Core"
      Role        = "Wireguard"
    })
    cidr              = string
    loganalytics_id   = string
    secure_origins_v4 = list(string)
    secure_origins_v6 = list(string)
  })
}

resource "azurerm_resource_group" "i" {
  name     = "${var.common.location}-wireguard"
  location = var.common.location

  tags = var.common.tags
}

resource "azurerm_public_ip" "i" {
  name                = azurerm_resource_group.i.name
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = var.common.tags
}

resource "azurerm_storage_account" "i" {
  name                = "bink${var.common.location}wireguard"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location

  cross_tenant_replication_enabled = false
  account_tier                     = "Standard"
  account_replication_type         = "ZRS"

  tags = var.common.tags
}

resource "azurerm_storage_share" "users" {
  name                 = "users"
  access_tier          = "TransactionOptimized"
  storage_account_name = azurerm_storage_account.i.name
  quota                = 50
}

resource "azurerm_virtual_network" "i" {
  name                = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  address_space       = [var.common.cidr]
  tags                = var.common.tags

  subnet {
    name           = "subnet"
    address_prefix = var.common.cidr
  }

  lifecycle { ignore_changes = [subnet] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
  name                  = azurerm_resource_group.i.name
  resource_group_name   = var.common.private_dns.resource_group
  private_dns_zone_name = var.common.private_dns.primary_zone
  virtual_network_id    = azurerm_virtual_network.i.id
  registration_enabled  = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
  for_each              = toset(var.common.private_dns.secondary_zones)
  name                  = azurerm_resource_group.i.name
  resource_group_name   = var.common.private_dns.resource_group
  private_dns_zone_name = each.key
  virtual_network_id    = azurerm_virtual_network.i.id
}

resource "azurerm_network_security_group" "i" {
  name                = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name

  tags = var.common.tags

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

  dynamic "security_rule" {
    for_each = { for id, cidr in concat(var.common.secure_origins_v4, var.common.secure_origins_v6) : cidr => id }
    content {
      name                       = "SSH_Rule_${security_rule.value}"
      access                     = "Allow"
      priority                   = security_rule.value + 500
      direction                  = "Inbound"
      protocol                   = "Tcp"
      source_address_prefix      = security_rule.key
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
    }
  }

  dynamic "security_rule" {
    for_each = {
      "Allow_UDP_51820" = { "priority" : "200", "port" : "51820", "source" : "*" },
    }
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      access                     = "Allow"
      protocol                   = "Udp"
      direction                  = "Inbound"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value.source
      destination_port_range     = security_rule.value.port
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
  name                       = "binkuksouthlogs"
  target_resource_id         = azurerm_network_security_group.i.id
  log_analytics_workspace_id = var.common.loganalytics_id

  enabled_log { category = "NetworkSecurityGroupEvent" }
  enabled_log { category = "NetworkSecurityGroupRuleCounter" }
}

resource "azurerm_route_table" "i" {
  name                          = azurerm_resource_group.i.name
  location                      = azurerm_resource_group.i.location
  resource_group_name           = azurerm_resource_group.i.name
  disable_bgp_route_propagation = true

  route {
    name                   = "barclays_sftp"
    address_prefix         = "157.83.104.20/32"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.common.firewall.ip_address
  }

  tags = var.common.tags
}

resource "azurerm_subnet_network_security_group_association" "i" {
  subnet_id                 = one(azurerm_virtual_network.i.subnet[*].id)
  network_security_group_id = azurerm_network_security_group.i.id
}

resource "azurerm_subnet_route_table_association" "i" {
  subnet_id      = one(azurerm_virtual_network.i.subnet[*].id)
  route_table_id = azurerm_route_table.i.id
}

resource "azurerm_virtual_network_peering" "firewall_to_local" {
  name                         = "local-to-${azurerm_resource_group.i.name}"
  resource_group_name          = var.common.firewall.resource_group
  virtual_network_name         = var.common.firewall.vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.i.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "local_to_firewall" {
  name                         = "${var.common.firewall.resource_group}-to-local"
  resource_group_name          = azurerm_resource_group.i.name
  virtual_network_name         = azurerm_virtual_network.i.name
  remote_virtual_network_id    = var.common.firewall.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_network_interface" "i" {
  name                = "wireguard"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = one(azurerm_virtual_network.i.subnet[*].id)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.i.id
  }
}

resource "azurerm_linux_virtual_machine" "i" {
  name                = "wireguard"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  size                = var.common.vm_size
  admin_username      = "terraform"
  tags                = var.common.tags
  network_interface_ids = [
    azurerm_network_interface.i.id,
  ]

  admin_ssh_key {
    username   = "terraform"
    public_key = file("ssh.pub")
  }

  os_disk {
    disk_size_gb         = 32
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
