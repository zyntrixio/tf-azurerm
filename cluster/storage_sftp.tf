resource "random_string" "sftp" {
  length      = 4
  upper       = false
  special     = false
  min_numeric = 2
}

resource "azurerm_storage_account" "sftp" {
  count = var.storage.sftp_enabled ? 1 : 0

  name                = "${replace(azurerm_resource_group.i.name, "-", "")}sftp${random_string.sftp.result}"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name

  account_tier                     = "Standard"
  min_tls_version                  = "TLS1_2"
  account_replication_type         = "ZRS"
  allow_nested_items_to_be_public  = true
  cross_tenant_replication_enabled = false

  is_hns_enabled = true
  sftp_enabled   = true
}

resource "azurerm_monitor_diagnostic_setting" "sftp" {
  count = var.storage.sftp_enabled && var.loganalytics.enabled ? 1 : 0

  name                       = "loganalytics"
  target_resource_id         = "${azurerm_storage_account.sftp[0].id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

  enabled_log { category = "StorageRead" }
  enabled_log { category = "StorageWrite" }
  enabled_log { category = "StorageDelete" }
  metric {
    category = "Capacity"
    enabled  = false
  }
  metric {
    category = "Transaction"
    enabled  = false
  }
}

resource "azurerm_role_assignment" "sftp_iam_ro" {
  for_each = {
    for k, v in var.iam : k => v
    if contains(v["assigned_to"], "st_ro") &&
    var.storage.sftp_enabled
  }

  scope                = azurerm_storage_account.sftp[0].id
  role_definition_name = "Reader"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "sftp_iam_rw" {
  for_each = {
    for k, v in var.iam : k => v
    if contains(v["assigned_to"], "st_rw") &&
    var.storage.sftp_enabled
  }

  scope                = azurerm_storage_account.sftp[0].id
  role_definition_name = "Contributor"
  principal_id         = each.key
}
