resource "azurerm_log_analytics_workspace" "i" {
    count = var.loganalytics.enabled ? 1 : 0

    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    sku = var.loganalytics.sku
    retention_in_days = var.loganalytics.retention_in_days
}
