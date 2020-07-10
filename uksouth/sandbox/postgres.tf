resource "random_password" "performance" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "performance" {
    name = "bink-performance-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    administrator_login = "laadmin"
    administrator_login_password = random_password.performance.result

    sku_name = "GP_Gen5_32"
    version = "11"
    storage_mb = 3145728

    backup_retention_days = 7
    geo_redundant_backup_enabled = false
    auto_grow_enabled = false

    public_network_access_enabled = true
    ssl_enforcement_enabled = true
    ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_postgresql_virtual_network_rule" "performance" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.performance.name
    subnet_id = azurerm_subnet.subnet.0.id
}

resource "azurerm_monitor_diagnostic_setting" "performance" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_postgresql_server.performance.id
    eventhub_name = "azurepostgres"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    log {
        category = "PostgreSQLLogs"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "QueryStoreRuntimeStatistics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "QueryStoreWaitStatistics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
    metric {
        category = "AllMetrics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
}

resource "random_password" "oat" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "oat" {
    name = "bink-oat-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    administrator_login = "laadmin"
    administrator_login_password = random_password.oat.result

    sku_name = "GP_Gen5_2"
    version = "11"
    storage_mb = 102400

    backup_retention_days = 7
    geo_redundant_backup_enabled = false
    auto_grow_enabled = false

    public_network_access_enabled = true
    ssl_enforcement_enabled = true
    ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_postgresql_virtual_network_rule" "oat" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.oat.name
    subnet_id = azurerm_subnet.subnet.0.id
}

resource "azurerm_monitor_diagnostic_setting" "oat" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_postgresql_server.oat.id
    eventhub_name = "azurepostgres"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    log {
        category = "PostgreSQLLogs"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "QueryStoreRuntimeStatistics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "QueryStoreWaitStatistics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
    metric {
        category = "AllMetrics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
}

resource "random_password" "sandbox" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "sandbox" {
    name = "bink-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    administrator_login = "laadmin"
    administrator_login_password = random_password.sandbox.result

    sku_name = "GP_Gen5_2"
    version = "11"
    storage_mb = 102400

    backup_retention_days = 7
    geo_redundant_backup_enabled = false
    auto_grow_enabled = false

    public_network_access_enabled = true
    ssl_enforcement_enabled = true
    ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_postgresql_virtual_network_rule" "sandbox" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.sandbox.name
    subnet_id = azurerm_subnet.subnet.0.id
}

resource "azurerm_monitor_diagnostic_setting" "sandbox" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_postgresql_server.sandbox.id
    eventhub_name = "azurepostgres"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    log {
        category = "PostgreSQLLogs"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "QueryStoreRuntimeStatistics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "QueryStoreWaitStatistics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
    metric {
        category = "AllMetrics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
}