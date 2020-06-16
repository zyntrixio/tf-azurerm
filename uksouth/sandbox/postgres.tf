resource "random_password" "performance" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "performance" {
    name = "bink-performance-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "GP_Gen5_8"

    storage_profile {
        storage_mb = 3145728
        backup_retention_days = 7
        geo_redundant_backup = "Disabled"
        auto_grow = "Disabled"
    }

    administrator_login = "laadmin"
    administrator_login_password = random_password.performance.result
    version = 11
    ssl_enforcement = "Enabled"
}

resource "azurerm_postgresql_virtual_network_rule" "performance" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.performance.name
    subnet_id = azurerm_subnet.subnet.0.id
}

resource "random_password" "oat" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "oat" {
    name = "bink-oat-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "GP_Gen5_2"

    storage_profile {
        storage_mb = 102400
        backup_retention_days = 7
        geo_redundant_backup = "Disabled"
        auto_grow = "Disabled"
    }

    administrator_login = "laadmin"
    administrator_login_password = random_password.oat.result
    version = 11
    ssl_enforcement = "Enabled"
}

resource "azurerm_postgresql_virtual_network_rule" "oat" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.oat.name
    subnet_id = azurerm_subnet.subnet.0.id
}

resource "random_password" "sandbox" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "sandbox" {
    name = "bink-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "GP_Gen5_2"

    storage_profile {
        storage_mb = 102400
        backup_retention_days = 7
        geo_redundant_backup = "Disabled"
        auto_grow = "Disabled"
    }

    administrator_login = "laadmin"
    administrator_login_password = random_password.sandbox.result
    version = 11
    ssl_enforcement = "Enabled"
}

resource "azurerm_postgresql_virtual_network_rule" "sandbox" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.sandbox.name
    subnet_id = azurerm_subnet.subnet.0.id
}

