resource "azurerm_resource_group" "i" {
    name = "uksouth-loganalytics"
    location = "uksouth"
}

resource "azurerm_role_assignment" "charlie" {
  scope                = azurerm_resource_group.i.id
  role_definition_name = "Contributor"
  principal_id         = "2ef70efe-8675-419d-97cb-4775828383cd"
}

resource "azurerm_log_analytics_workspace" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    sku = "PerGB2018"
    retention_in_days = 90
}

output "loganalytics_id" {
    value = azurerm_log_analytics_workspace.i.id
}
