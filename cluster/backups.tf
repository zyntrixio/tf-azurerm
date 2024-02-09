resource "azurerm_role_assignment" "backups_storage" {
  scope                = azurerm_resource_group.i.id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = var.backups.principal_id
}

resource "azurerm_role_assignment" "backups_postgres" {
  scope                = azurerm_resource_group.i.id
  role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
  principal_id         = var.backups.principal_id
}

# This one shouldn't be required, but the Postgres Flexible Role lacks required permissions.
# If the following gets fixed in future versions, this resource can be removed.
# Current JSON:
# "actions": [
#     "Microsoft.DBforPostgreSQL/flexibleServers/ltrBackupOperations/read",
#     "Microsoft.DBforPostgreSQL/flexibleServers/ltrPreBackup/action",
#     "Microsoft.DBforPostgreSQL/flexibleServers/startLtrBackup/action",
#     "Microsoft.DBforPostgreSQL/locations/azureAsyncOperation/read",
#     "Microsoft.DBforPostgreSQL/locations/operationResults/read",
#     "Microsoft.Resources/subscriptions/read",
#     "Microsoft.Resources/subscriptions/resourceGroups/read"
# ],
# Missing: "Microsoft.DBforPostgreSQL/flexibleServers/read"
resource "azurerm_role_assignment" "backups_reader" {
  scope                = azurerm_resource_group.i.id
  role_definition_name = "Reader"
  principal_id         = var.backups.principal_id
}

resource "azurerm_data_protection_backup_instance_blob_storage" "i" {
  provider = azurerm.core

  name               = azurerm_storage_account.i.name
  vault_id           = var.backups.resource_id
  location           = azurerm_resource_group.i.location
  storage_account_id = azurerm_storage_account.i.id
  backup_policy_id   = var.backups.policies.blob_storage

  depends_on = [azurerm_role_assignment.backups_storage]
}
