variable "common" {
  type = object({
    location   = optional(string, "uksouth")
    redundancy = optional(string, "GeoRedundant")
  })
}

resource "azurerm_resource_group" "i" {
  name     = "${var.common.location}-backups"
  location = var.common.location
}

resource "azurerm_data_protection_backup_vault" "i" {
  name                = azurerm_resource_group.i.name
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  datastore_type      = "VaultStore"
  redundancy          = var.common.redundancy
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_blob_storage" "i" {
  name               = "BlobStorage"
  vault_id           = azurerm_data_protection_backup_vault.i.id
  retention_duration = "P6M"
}

# TODO: Add support for PostgreSQL Flexible Server Long Term Retention Backup Policies, once available.

output "resource_id" {
  value = azurerm_data_protection_backup_vault.i.id
}

output "principal_id" {
  value = azurerm_data_protection_backup_vault.i.identity[0].principal_id
}

output "policies" {
  value = {
    blob_storage = azurerm_data_protection_backup_policy_blob_storage.i.id,
    postgres     = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-backups/providers/Microsoft.DataProtection/backupVaults/uksouth-backups/backupPolicies/Postgres"
  }
}
