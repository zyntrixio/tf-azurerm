resource "azurerm_virtual_network" "vnet" {
  name                = "firewall-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.ip_range]
}

resource "azurerm_subnet" "subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.ip_range]
}

resource "azurerm_public_ip_prefix" "prefix" {
  name                = "firewall-pip-prefix"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  prefix_length       = 28
  zones               = ["1", "2", "3"]
}

resource "azurerm_public_ip" "pips" {
  count                   = 16
  name                    = format("firewall-pip-prefix-%02d", count.index + 1)
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 5
  public_ip_prefix_id     = azurerm_public_ip_prefix.prefix.id
  zones                   = ["1", "2", "3"]
}

# TODO: Cleanup the below IP Config Blocks by using Terraform 0.12 Syntax
resource "azurerm_firewall" "firewall" {
  name                = "firewall"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "ipconfig0"
    subnet_id            = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.pips.0.id
  }
  ip_configuration {
    name                 = "ipconfig1"
    public_ip_address_id = azurerm_public_ip.pips.1.id
  }
  ip_configuration {
    name                 = "ipconfig2"
    public_ip_address_id = azurerm_public_ip.pips.2.id
  }
  ip_configuration {
    name                 = "ipconfig3"
    public_ip_address_id = azurerm_public_ip.pips.3.id
  }
  ip_configuration {
    name                 = "ipconfig4"
    public_ip_address_id = azurerm_public_ip.pips.4.id
  }
  ip_configuration {
    name                 = "ipconfig5"
    public_ip_address_id = azurerm_public_ip.pips.5.id
  }
  ip_configuration {
    name                 = "ipconfig6"
    public_ip_address_id = azurerm_public_ip.pips.6.id
  }
  ip_configuration {
    name                 = "ipconfig7"
    public_ip_address_id = azurerm_public_ip.pips.7.id
  }
  ip_configuration {
    name                 = "ipconfig8"
    public_ip_address_id = azurerm_public_ip.pips.8.id
  }
  ip_configuration {
    name                 = "ipconfig9"
    public_ip_address_id = azurerm_public_ip.pips.9.id
  }
  ip_configuration {
    name                 = "ipconfig10"
    public_ip_address_id = azurerm_public_ip.pips.10.id
  }
  ip_configuration {
    name                 = "ipconfig11"
    public_ip_address_id = azurerm_public_ip.pips.11.id
  }
  ip_configuration {
    name                 = "ipconfig12"
    public_ip_address_id = azurerm_public_ip.pips.12.id
  }
  ip_configuration {
    name                 = "ipconfig13"
    public_ip_address_id = azurerm_public_ip.pips.13.id
  }
  ip_configuration {
    name                 = "ipconfig14"
    public_ip_address_id = azurerm_public_ip.pips.14.id
  }
  ip_configuration {
    name                 = "ipconfig15"
    public_ip_address_id = azurerm_public_ip.pips.15.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "i" {
  name                           = "loganalytics"
  target_resource_id             = azurerm_firewall.firewall.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.i.id
  log_analytics_destination_type = "Dedicated"

  enabled_log { category = "AZFWNetworkRule" }
  enabled_log { category = "AZFWApplicationRule" }
  enabled_log { category = "AZFWNatRule" }
  enabled_log { category = "AZFWThreatIntel" }
  enabled_log { category = "AZFWIdpsSignature" }
  enabled_log { category = "AZFWDnsQuery" }
  enabled_log { category = "AZFWFqdnResolveFailure" }
  enabled_log { category = "AZFWFatFlow" }
  enabled_log { category = "AZFWFlowTrace" }
  enabled_log { category = "AZFWApplicationRuleAggregation" }
  enabled_log { category = "AZFWNetworkRuleAggregation" }
  enabled_log { category = "AZFWNatRuleAggregation" }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}
