resource "azurerm_key_vault_secret" "st" {
  count = var.keyvault.enabled ? 1 : 0

  name         = "infra-storage-connection-details"
  key_vault_id = azurerm_key_vault.i[0].id
  content_type = "application/json"
  value = jsonencode({
    # old keys
    "connection_string_primary"   = azurerm_storage_account.i.primary_connection_string,
    "connection_string_secondary" = azurerm_storage_account.i.secondary_connection_string,
    "account_name"                = azurerm_storage_account.i.name,
    "key_primary"                 = azurerm_storage_account.i.primary_access_key,
    "key_secondary"               = azurerm_storage_account.i.secondary_access_key,

    # new keys
    "blob_connection_string_primary"   = azurerm_storage_account.i.primary_connection_string,
    "blob_connection_string_secondary" = azurerm_storage_account.i.secondary_connection_string,
    "blob_account_name"                = azurerm_storage_account.i.name,
    "blob_resource_group"              = azurerm_resource_group.i.name,
    "blob_key_primary"                 = azurerm_storage_account.i.primary_access_key,
    "blob_key_secondary"               = azurerm_storage_account.i.secondary_access_key,

    "sftp_connection_string_primary"   = try(azurerm_storage_account.sftp[0].primary_connection_string, ""),
    "sftp_connection_string_secondary" = try(azurerm_storage_account.sftp[0].secondary_connection_string, ""),
    "sftp_account_name"                = try(azurerm_storage_account.sftp[0].name, ""),
    "sftp_resource_group"              = azurerm_resource_group.i.name,
    "sftp_key_primary"                 = try(azurerm_storage_account.sftp[0].primary_access_key, ""),
    "sftp_key_secondary"               = try(azurerm_storage_account.sftp[0].secondary_access_key, ""),
  })
  tags = {
    kube_secret_name = "azure-storage"
  }

  depends_on = [azurerm_key_vault_access_policy.iam_su]
}
