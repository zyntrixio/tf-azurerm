resource "random_password" "pg" {
    for_each = var.postgres_config

    length = 24
    special = false
}

resource "azurerm_postgresql_server" "pg" {
    for_each = var.postgres_config

    name = each.value["name"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags = var.tags

    administrator_login = each.key
    administrator_login_password = random_password.pg[each.key].result

    sku_name = lookup(each.value, "sku_name", "GP_Gen5_2")
    version = lookup(each.value, "version", "11")
    storage_mb = lookup(each.value, "storage_gb", 100) * 1024

    backup_retention_days = lookup(each.value, "backup_retention_days", 7)
    geo_redundant_backup_enabled = lookup(each.value, "geo_redundant_backup_enabled", false)
    auto_grow_enabled = lookup(each.value, "auto_grow_enabled", false)

    public_network_access_enabled = lookup(each.value, "public_network_access_enabled", false)
    ssl_enforcement_enabled = lookup(each.value, "ssl_enforcement_enabled", true)
    ssl_minimal_tls_version_enforced = lookup(each.value, "ssl_minimal_tls_version_enforced", "TLS1_2")
}

resource "azurerm_key_vault_secret" "pg_individual_pass" {
    for_each = var.postgres_config

    name = "infra-${each.key}"
    value = jsonencode({
        "host" : azurerm_postgresql_server.pg[each.key].fqdn,
        "port" : "5432",
        "admin_user" : "${azurerm_postgresql_server.pg[each.key].administrator_login}@${azurerm_postgresql_server.pg[each.key].name}",
        "password" : random_password.pg[each.key].result
    })
    content_type = "application/json"
    key_vault_id = azurerm_key_vault.infra.id

    tags = {
        k8s_secret_name = "azure-pg-${each.key}"
        k8s_namespaces = "default"
        # k8s_convert = "file:/app/templates/pgbouncer.yaml"
    }
}
