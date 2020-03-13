provider "azurerm" {
  version = "~> 1.44"
  subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
  client_id = "98e2ee67-a52d-40fc-9b39-155887530a7b"
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
}

terraform {
  backend "azurerm" {
    storage_account_name = "binkitops"
    container_name = "terraform"
    key = "storage.tfstate"
  }
}

resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "itops" {
  name = "binkitops"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "GRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkopsreports" {
  name = "binkopsreports"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkopsreportsdev" {
  name = "binkopsreportsdev"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkopsreportsstaging" {
  name = "binkopsreportsstaging"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkbackupsdev" {
  name = "binkbackupsdev"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkbackupsstaging" {
  name = "binkbackupsstaging"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkbackupsprod" {
  name = "binkbackupsprod"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "GRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkdbbackupsdev" {
  name = "binkdbbackupsdev"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkdbbackupsstaging" {
  name = "binkdbbackupsstaging"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkdbbackupsprod" {
  name = "binkdbbackupsprod"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkmediabackupsdev" {
  name = "binkmediabackupsdev"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkmediabackupsstaging" {
  name = "binkmediabackupsstaging"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkmediabackupsprod" {
  name = "binkmediabackupsprod"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "binkgitlabbackups" {
  name = "binkgitlabbackups"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "aphrodite" {
  name = "aphrodite"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "GRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "aphroditestaging" {
  name = "aphroditestaging"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "bink" {
  name = "bink"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "GRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "harmonia" {
  name = "harmonia"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "harmoniastaging" {
  name = "harmoniastaging"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "harmoniadev" {
  name = "harmoniadev"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_account" "thoughtspot" {
  name = "thoughtspot"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  account_kind = "BlobStorage"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_container_registry" "binkdemo" {
  name = "binkdemo"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  sku = "Standard"
  admin_enabled = true
}

resource "azurerm_container_registry" "binkiceland" {
  name = "binkiceland"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  sku = "Basic"
  admin_enabled = true
}

resource "azurerm_container_registry" "binkops" {
  name = "binkops"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  sku = "Premium"
  admin_enabled = true
  georeplication_locations = ["UK South", "UK West"]
}

resource "azurerm_container_registry" "mygravity" {
  name = "mygravity"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  sku = "Basic"
  admin_enabled = true
}

resource "azurerm_container_registry" "olympus" {
  name = "olympus"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  sku = "Premium"
  admin_enabled = true
  georeplication_locations = ["UK South", "UK West"]
}
