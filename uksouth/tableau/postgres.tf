
resource "random_password" "pg_pass" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "postgres" {
    name = "bink-tableau-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "GP_Gen5_4"

    storage_profile {
        storage_mb = 102400
        backup_retention_days = 7
        geo_redundant_backup = "Disabled"
        auto_grow = "Disabled"
    }

    administrator_login = "laadmin"
    administrator_login_password = random_password.pg_pass.result
    version = 11
    ssl_enforcement = "Enabled"
}

resource "azurerm_postgresql_firewall_rule" "binkhq" {
    name = "binkhq"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    start_ip_address = "194.74.152.11"
    end_ip_address = "194.74.152.11"
}

resource "azurerm_postgresql_virtual_network_rule" "workers" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    subnet_id = var.worker_subnet
}

# TODO Remove after Covid19
resource "azurerm_postgresql_firewall_rule" "chris_gormley" {
    name = "chris_gormley"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    start_ip_address = "82.11.7.50"
    end_ip_address = "82.11.7.50"
}
resource "azurerm_postgresql_firewall_rule" "terry_cain" {
    name = "terry_cain"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    start_ip_address = "86.28.118.165"
    end_ip_address = "86.28.118.165"
}
