# locals {
#     connection_strings = [
#         { for database in var.postgres.databases: database => "${database}" }
#     ]
# }

resource "azurerm_private_dns_zone" "pg" {
    name = "private.postgres.database.azure.com"
    resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pg" {
    name = "private.postgres.database.azure.com"
    private_dns_zone_name = azurerm_private_dns_zone.pg.name
    virtual_network_id = azurerm_virtual_network.i.id
    resource_group_name = azurerm_resource_group.i.name
}

resource "random_string" "pg" {
    length = 4
    upper = false
    special = false
    min_numeric = 2
}

resource "random_pet" "pg" {
    length = 1
}

resource "random_password" "pg" {
    length = 24
    special = false
}

resource "azurerm_postgresql_flexible_server" "i" {
    count = var.postgres.enabled ? 1 : 0

    name = "${azurerm_resource_group.i.name}-${random_string.pg.result}"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location

    sku_name = var.postgres.sku
    version = var.postgres.version

    delegated_subnet_id = azurerm_subnet.postgres.id
    private_dns_zone_id = azurerm_private_dns_zone.pg.id

    administrator_login = random_pet.pg.id
    administrator_password = random_password.pg.result

    storage_mb = var.postgres.storage_mb

    dynamic "high_availability" {
        for_each = var.postgres.ha ? [1] : []
        content {
            mode = "ZoneRedundant"
        }
    }
    depends_on = [azurerm_private_dns_zone_virtual_network_link.pg]
    lifecycle {
        ignore_changes = [zone, high_availability.0.standby_availability_zone]
    }
}

resource "azurerm_monitor_diagnostic_setting" "pg" {
    count = var.postgres.enabled && var.loganalytics.enabled ? 1 : 0

    name = "loganalytics"
    target_resource_id = azurerm_postgresql_flexible_server.i[0].id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

    enabled_log { category = "PostgreSQLLogs" }
    metric {
        enabled = true
        category = "AllMetrics"
    }
}

resource "azurerm_role_assignment" "pg_mi" {
    for_each = {
        for k, v in var.managed_identities : k => v
            if contains(v["assigned_to"], "pg") &&
            var.postgres.enabled
    }

    scope = azurerm_postgresql_flexible_server.i[0].id
    role_definition_name = "Contributor"
    principal_id = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "pg_iam" {
    for_each = {
        for k, v in var.iam : k => v
            if contains(v["assigned_to"], "pg") &&
            var.postgres.enabled
    }

    scope = azurerm_postgresql_flexible_server.i[0].id
    role_definition_name = "Contributor"
    principal_id = each.key
}

resource "azurerm_key_vault_secret" "pg" {
    count = var.postgres.enabled && var.keyvault.enabled ? 1 : 0

    name = "infra-postgres-connection-details"
    key_vault_id = azurerm_key_vault.i[0].id
    content_type = "application/json"
    value = jsonencode(merge({
        for database in var.postgres.databases : "url_${database}" => "postgresql://${random_pet.pg.id}:${random_password.pg.result}@${azurerm_postgresql_flexible_server.i[0].fqdn}/${database}?sslmode=require"
    }, {
        "server_host": azurerm_postgresql_flexible_server.i[0].fqdn,
        "server_user": random_pet.pg.id,
        "server_pass": random_password.pg.result,
        "url_placeholder": "postgresql://${random_pet.pg.id}:${random_password.pg.result}@${azurerm_postgresql_flexible_server.i[0].fqdn}/{}?sslmode=require"
    }))
    tags = {
        k8s_secret_name = "azure-postgres"
    }

    depends_on = [ azurerm_key_vault_access_policy.iam_su ]
}
