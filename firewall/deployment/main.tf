variable "location" {
  type = string
}

variable "ip_range" {
  type = string
}

variable "policy_id" {
  type = string
}

variable "sku" {
  type    = string
  default = "Basic"
}

resource "azurerm_resource_group" "i" {
  name     = "${var.location}-fw"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "i" {
  name                = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_virtual_network" "i" {
  name                = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  address_space       = [var.ip_range]
}

resource "azurerm_subnet" "i" {
  count                = 2
  name                 = count.index == 0 ? "AzureFirewallSubnet" : "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.i.name
  virtual_network_name = azurerm_virtual_network.i.name
  address_prefixes     = count.index == 0 ? [cidrsubnet(var.ip_range, 1, 0)] : [cidrsubnet(var.ip_range, 1, 1)]
}

resource "azurerm_public_ip_prefix" "i" {
  name                = azurerm_resource_group.i.name
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  prefix_length       = 31
  zones               = ["1", "2", "3"]
}

resource "azurerm_public_ip" "i" {
  count               = 2
  name                = "${azurerm_resource_group.i.name}-${count.index}"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  public_ip_prefix_id = azurerm_public_ip_prefix.i.id
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_firewall" "i" {
  name                = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku
  firewall_policy_id  = var.policy_id

  // Use one IP Configuration + a Management Configuration for Basic SKU
  // Use two IP Configurations for Standard/Premium SKU
  dynamic "ip_configuration" {
    for_each = var.sku == "Basic" ? range(1) : range(2)
    content {
      name                 = "ipconfig-${ip_configuration.key}"
      subnet_id            = azurerm_subnet.i[0].id
      public_ip_address_id = azurerm_public_ip.i[ip_configuration.key].id
    }
  }
  dynamic "management_ip_configuration" {
    for_each = var.sku == "Basic" ? range(1) : range(0)
    content {
      name                 = "ipconfig-mgmt"
      subnet_id            = azurerm_subnet.i[1].id
      public_ip_address_id = azurerm_public_ip.i[1].id
    }
  }
}

output "peer_info" {
  value = {
    resource_group_name = azurerm_resource_group.i.name
    vnet_name           = azurerm_virtual_network.i.name
    vnet_id             = azurerm_virtual_network.i.id
    ip                  = azurerm_firewall.i.ip_configuration[0].private_ip_address
    v4_prefix           = azurerm_public_ip_prefix.i.ip_prefix
  }
}
