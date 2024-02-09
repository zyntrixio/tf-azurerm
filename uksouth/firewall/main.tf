resource "azurerm_resource_group" "rg" {
  name     = "uksouth-firewall"
  location = "uksouth"
}

resource "azurerm_log_analytics_workspace" "i" {
  name                = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}
