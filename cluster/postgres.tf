locals {
    postgres_identity_map = merge(flatten([
        for pg_key, pg_value in var.postgres : {
            for mi_key, mi_value in var.managed_identities :
                "${pg_key}-${mi_key}" => {postgres_server = pg_key, identity = mi_key}
                if contains(mi_value["assigned_to"], "pg") }
    ])...)
    postgres_iam_map = merge(flatten([
        for pg_key, pg_value in var.postgres : {
            for iam_key, iam_value in var.iam :
                "${pg_key}-${iam_key}" => {postgres_server = pg_key, identity = iam_key}
                if contains(iam_value["assigned_to"], "pg") }
    ])...)
}

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
    for_each = var.postgres
    length = 4
    upper = false
    special = false
    min_numeric = 2
}

moved {
    from = random_string.pg
    to = random_string.pg["core"]
}

resource "random_pet" "pg" {
    for_each = var.postgres
    length = 1
}

moved {
    from = random_pet.pg
    to = random_pet.pg["core"]
}

resource "random_password" "pg" {
    for_each = var.postgres
    length = 24
    special = false
}

moved {
    from = random_password.pg
    to = random_password.pg["core"]
}

resource "azurerm_postgresql_flexible_server" "i" {
    for_each = var.postgres

    name = "${azurerm_resource_group.i.name}-${random_string.pg[each.key].result}"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location

    sku_name = each.value.sku
    version = each.value.version

    delegated_subnet_id = azurerm_subnet.postgres.id
    private_dns_zone_id = azurerm_private_dns_zone.pg.id

    administrator_login = random_pet.pg[each.key].id
    administrator_password = random_password.pg[each.key].result

    storage_mb = each.value.storage_mb
    backup_retention_days = each.value.backup_retention_days

    dynamic "high_availability" {
        for_each = each.value.ha ? [1] : []
        content {
            mode = "ZoneRedundant"
        }
    }
    depends_on = [azurerm_private_dns_zone_virtual_network_link.pg]
    lifecycle {
        ignore_changes = [zone, high_availability.0.standby_availability_zone]
    }
}

moved {
    from = azurerm_postgresql_flexible_server.i[0]
    to = azurerm_postgresql_flexible_server.i["core"]
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
    for_each = var.postgres

    name = "azure.extensions"
    server_id = azurerm_postgresql_flexible_server.i[each.key].id
    value = "UUID-OSSP,PG_TRGM"
}

moved {
    from = azurerm_postgresql_flexible_server_configuration.extensions[0]
    to = azurerm_postgresql_flexible_server_configuration.extensions["core"]
}

resource "azurerm_monitor_diagnostic_setting" "pg" {
    for_each = var.loganalytics.enabled ? var.postgres : {}

    name = "loganalytics"
    target_resource_id = azurerm_postgresql_flexible_server.i[each.key].id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

    metric {
        enabled = true
        category = "AllMetrics"
    }
}

moved {
    from = azurerm_monitor_diagnostic_setting.pg[0]
    to = azurerm_monitor_diagnostic_setting.pg["core"]
}

resource "azurerm_role_assignment" "pg_mi" {
    for_each = local.postgres_identity_map

    scope = azurerm_postgresql_flexible_server.i[each.value.postgres_server].id
    role_definition_name = "Contributor"
    principal_id = azurerm_user_assigned_identity.i[each.value.identity].principal_id
}

resource "azurerm_role_assignment" "pg_iam" {
    for_each = local.postgres_iam_map

    scope = azurerm_postgresql_flexible_server.i[each.value.postgres_server].id
    role_definition_name = "Contributor"
    principal_id = each.value.identity
}

resource "azurerm_key_vault_secret" "pg" {
    for_each = var.postgres

    name = "infra-postgres-connection-details-${each.key}"
    key_vault_id = azurerm_key_vault.i[0].id
    content_type = "application/json"
    value = jsonencode(merge({
        for database in concat(each.value.databases) :
            "url_${database}" => "postgresql://${random_pet.pg[each.key].id}:${random_password.pg[each.key].result}@${azurerm_postgresql_flexible_server.i[each.key].fqdn}/${database}?sslmode=require"
    }, {
        "server_host": azurerm_postgresql_flexible_server.i[each.key].fqdn,
        "server_user": random_pet.pg[each.key].id,
        "server_pass": random_password.pg[each.key].result,
        "url_placeholder": "postgresql://${random_pet.pg[each.key].id}:${random_password.pg[each.key].result}@${azurerm_postgresql_flexible_server.i[each.key].fqdn}/{}?sslmode=require"
    }))
    tags = {
        kube_secret_name = "azure-postgres-${each.key}"
    }

    depends_on = [ azurerm_key_vault_access_policy.iam_su ]
}
