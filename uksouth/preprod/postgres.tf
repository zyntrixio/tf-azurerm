resource "random_password" "pg_pass" {
    length = 24
    special = false
}

resource "azurerm_postgresql_server" "postgres" {
    name = "bink-preprod-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    administrator_login = "laadmin"
    administrator_login_password = random_password.pg_pass.result

    sku_name = "GP_Gen5_2"
    version = "11"
    storage_mb = 1024000

    backup_retention_days = 7
    geo_redundant_backup_enabled = false
    auto_grow_enabled = false

    public_network_access_enabled = true
    ssl_enforcement_enabled = true
    ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

# Allow prod kube workers to access
# resource "azurerm_postgresql_virtual_network_rule" "workers" {
#     name = "workers"
#     resource_group_name = azurerm_resource_group.rg.name
#     server_name = azurerm_postgresql_server.postgres.name
#     subnet_id = var.worker_subnet
# }

# TODO remove
resource "azurerm_postgresql_firewall_rule" "terry_temp" {
    name = "terry"
    resource_group_name = azurerm_resource_group.rg.name
    server_name = azurerm_postgresql_server.postgres.name
    start_ip_address = "82.24.92.107"
    end_ip_address = "82.24.92.107"
}
