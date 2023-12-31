resource "azurerm_data_protection_backup_vault" "i" {
    count = var.backups.enabled ? 1 : 0

    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    datastore_type = "VaultStore"
    redundancy = var.backups.redundancy
    identity {
        type = "SystemAssigned"
    }
}

resource "azurerm_role_assignment" "backups_storage" {
    count = var.backups.enabled ? 1 : 0

    scope = azurerm_storage_account.i[0].id
    role_definition_name = "Storage Account Backup Contributor"
    principal_id = azurerm_data_protection_backup_vault.i[0].identity[0].principal_id
}

# This cannot be enabled until support for Vaulted Backups is added to Terraform.
# The backup process should be as follows:
#   Operational Backups (daily) -> Vaulted Backups (weekly) -> Long Term Backups (monthly)
# Retention periods should be:
#   Operational Backups: 30 days
#   Vaulted Backups: 90 days
#   Long Term Backups: 3 years

# resource "azurerm_data_protection_backup_policy_blob_storage" "i" {
#     count = var.backups.enabled ? 1 : 0

#     name = "BlobStorage"
#     vault_id = azurerm_data_protection_backup_vault.i[0].id
#     retention_duration = var.backups.blob_retention_period
# }

# resource "azurerm_data_protection_backup_instance_blob_storage" "i" {
#     name               = "blob_storage"
#     vault_id           = azurerm_data_protection_backup_vault.i.id
#     location           = azurerm_resource_group.i.location
#     storage_account_id = azurerm_storage_account.i[0].id
#     backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.i.id

#     depends_on = [azurerm_role_assignment.backups_storage]
# }
