variable "loganalytics_workspace_id" {
  type = string
}

resource "azurerm_resource_group" "rg" {
  name     = "uksouth-core"
  location = "uksouth"
}

resource "azurerm_container_registry" "i" {
  name                = "binkcore"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true
  georeplications {
    location = "ukwest"
  }
}

resource "azurerm_monitor_diagnostic_setting" "binkcore" {
  name                       = "loganalytics"
  target_resource_id         = azurerm_container_registry.i.id
  log_analytics_workspace_id = var.loganalytics_workspace_id

  enabled_log { category = "ContainerRegistryRepositoryEvents" }
  enabled_log { category = "ContainerRegistryLoginEvents" }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

output "acr_id" {
  value = azurerm_container_registry.i.id
}
