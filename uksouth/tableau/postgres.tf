
resource "random_password" "pg_pass" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "postgres" {
    name = "bink-tableau-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    administrator_login = "laadmin"
    administrator_login_password = random_password.pg_pass.result

    sku_name = "GP_Gen5_4"
    version = "11"
    storage_mb = 102400

    backup_retention_days = 7
    geo_redundant_backup_enabled = false
    auto_grow_enabled = false

    public_network_access_enabled = true
    ssl_enforcement_enabled = true
    ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_postgresql_firewall_rule" "binkhq" {
    name = "binkhq"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    start_ip_address = "194.74.152.11"
    end_ip_address = "194.74.152.11"
}

resource "azurerm_postgresql_firewall_rule" "wireguard_vpn_uk" {
    name = "wireguard_vpn_uk"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    start_ip_address = var.wireguard_ip
    end_ip_address = var.wireguard_ip
}

resource "azurerm_postgresql_virtual_network_rule" "workers" {
    name = "workers"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    subnet_id = var.worker_subnet
}


resource "azurerm_postgresql_virtual_network_rule" "tableauserver" {
    name = "tableauserver"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    subnet_id = azurerm_subnet.subnet.id
}
