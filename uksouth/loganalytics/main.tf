resource "azurerm_resource_group" "i" {
    name = "uksouth-loganalytics"
    location = "uksouth"
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
