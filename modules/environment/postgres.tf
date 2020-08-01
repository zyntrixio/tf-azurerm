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
