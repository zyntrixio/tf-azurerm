# binkuksouthprodweb

resource "azurerm_storage_account" "binkwebprod" {
    name = "binkuksouthprodweb"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    tags = {
        "Environment" = "Production",
    }

    account_kind = "StorageV2"
    account_tier = "Standard"
    account_replication_type = "ZRS"
    min_tls_version = "TLS1_2"
    enable_https_traffic_only = true
    allow_blob_public_access = true

    static_website {
        index_document = "index.html"
    }
}

resource "azurerm_monitor_diagnostic_setting" "storage" {
    name = "logs"
    target_resource_id = "${azurerm_storage_account.binkwebprod.id}/blobServices/default"
    eventhub_name = "azurestorage"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    log_analytics_workspace_id = var.loganalytics_id

    log {
        category = "StorageRead"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "StorageWrite"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "StorageDelete"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }

    metric {
        category = "Capacity"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }

    metric {
        category = "Transaction"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
}
