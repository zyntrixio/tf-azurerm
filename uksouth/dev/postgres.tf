resource "random_password" "pg_pass" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "postgres" {
    name = "bink-dev-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    administrator_login = "laadmin"
    administrator_login_password = random_password.pg_pass.result

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

resource "azurerm_key_vault_secret" "dev_pg_pass" {
    name = "infra-dev-uksouth"
    value = jsonencode({
        "host" : azurerm_postgresql_server.postgres.fqdn,
        "port" : "5432",
        "admin_user" : "${azurerm_postgresql_server.postgres.administrator_login}@${azurerm_postgresql_server.postgres.name}",
        "password" : random_password.pg_pass.result
    })
    content_type = "application/json"
    key_vault_id = module.kv.keyvault.id

    tags = {
        k8s_secret_name = "pg-test"
        k8s_namespaces = "default"
        k8s_convert = "/app/templates/pgbouncer.yaml"
    }
}

resource "azurerm_postgresql_virtual_network_rule" "workers" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    subnet_id = azurerm_subnet.subnet.0.id
}

resource "azurerm_monitor_diagnostic_setting" "diags" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_postgresql_server.postgres.id
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
