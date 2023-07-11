resource "azurerm_data_protection_backup_vault" "i" {
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
    scope = azurerm_storage_account.i[0].id
    role_definition_name = "Storage Account Backup Contributor"
    principal_id = azurerm_data_protection_backup_vault.i.identity[0].principal_id
}

resource "azurerm_data_protection_backup_policy_blob_storage" "i" {
    name = "BlobStorage"
    vault_id = azurerm_data_protection_backup_vault.i.id
    retention_duration = "P3M"
}

resource "azurerm_data_protection_backup_instance_blob_storage" "i" {
    name               = "blob_storage"
    vault_id           = azurerm_data_protection_backup_vault.i.id
    location           = azurerm_resource_group.i.location
    storage_account_id = azurerm_storage_account.i[0].id
    backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.i.id

    depends_on = [azurerm_role_assignment.backups_storage]
}
