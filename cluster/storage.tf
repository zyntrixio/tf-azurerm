resource "azurerm_storage_account" "i" {
    count = var.storage.enabled ? 1 : 0

    name = replace(azurerm_resource_group.i.name, "-", "")
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name

    account_tier = "Standard"
    min_tls_version = "TLS1_2"
    account_replication_type = "ZRS"
    allow_nested_items_to_be_public = true
    cross_tenant_replication_enabled = false
}

resource "azurerm_monitor_diagnostic_setting" "st" {
    count = var.storage.enabled && var.loganalytics.enabled ? 1 : 0

    name = "loganalytics"
    target_resource_id = "${azurerm_storage_account.i[0].id}/blobServices/default"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

    enabled_log { category = "StorageRead" }
    enabled_log { category = "StorageWrite" }
    enabled_log { category = "StorageDelete" }
    metric {
        category = "Capacity"
        enabled = false
    }
    metric {
        category = "Transaction"
        enabled = false
    }
}
