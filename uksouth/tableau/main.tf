provider "azurerm" {
  version = "~> 2.2.0"
  subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
  client_id = "98e2ee67-a52d-40fc-9b39-155887530a7b"
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "random" {
  version = "~> 2.2"
}

terraform {
  backend "azurerm" {
    storage_account_name = "binkitops"
    container_name = "terraform"
    key = "tableau.tfstate"
  }
}

resource "azurerm_resource_group" "rg" {
  name = "uksouth-tableau"
  location = "uksouth"

  tags = var.tags
}

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
