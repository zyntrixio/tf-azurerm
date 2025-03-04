resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "itops" {
  name                = "binkitops"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  cross_tenant_replication_enabled = false
  account_kind                     = "BlobStorage"
  account_tier                     = "Standard"
  account_replication_type         = "GRS"
  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
}

resource "azurerm_storage_account" "binkarchives" {
  name                = "binkarchives"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  cross_tenant_replication_enabled = false
  account_kind                     = "BlobStorage"
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
}
