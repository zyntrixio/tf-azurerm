resource "random_password" "pg_pass" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "postgres" {
    name = "bink-prod-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "GP_Gen5_8"

    storage_profile {
        storage_mb = 1024000
        backup_retention_days = 7
        geo_redundant_backup = "Disabled"
        auto_grow = "Disabled"
    }

    administrator_login = "laadmin"
    administrator_login_password = random_password.pg_pass.result
    version = 11
    ssl_enforcement = "Enabled"
}

resource "azurerm_postgresql_virtual_network_rule" "workers" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    subnet_id = azurerm_subnet.subnet.0.id
}
