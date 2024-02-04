resource "random_string" "st" {
  length      = 4
  upper       = false
  special     = false
  min_numeric = 2
}

resource "azurerm_storage_account" "i" {
  count = var.storage.enabled ? 1 : 0

  name                = "${replace(azurerm_resource_group.i.name, "-", "")}${random_string.st.result}"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name

  account_tier                     = "Standard"
  min_tls_version                  = "TLS1_2"
  account_replication_type         = "ZRS"
  allow_nested_items_to_be_public  = true
  cross_tenant_replication_enabled = false
}

resource "azurerm_monitor_diagnostic_setting" "blob" {
  count = var.storage.enabled && var.loganalytics.enabled ? 1 : 0

  name                       = "loganalytics"
  target_resource_id         = "${azurerm_storage_account.i[0].id}/blobServices/default"
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

resource "azurerm_role_assignment" "st_mi_ro" {
  for_each = {
    for k, v in local.identities : k => v
    if contains(v["assigned_to"], "st_ro") &&
    var.storage.enabled
  }

  scope                = azurerm_storage_account.i[0].id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "st_mi_rw" {
  for_each = {
    for k, v in local.identities : k => v
    if contains(v["assigned_to"], "st_rw") &&
    var.storage.enabled
  }

  scope                = azurerm_storage_account.i[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "st_iam_ro" {
  for_each = {
    for k, v in var.iam : k => v
    if contains(v["assigned_to"], "st_ro") &&
    var.storage.enabled
  }

  scope                = azurerm_storage_account.i[0].id
  role_definition_name = "Reader"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "st_iam_rw" {
  for_each = {
    for k, v in var.iam : k => v
    if contains(v["assigned_to"], "st_rw") &&
    var.storage.enabled
  }

  scope                = azurerm_storage_account.i[0].id
  role_definition_name = "Contributor"
  principal_id         = each.key
}

resource "azurerm_storage_management_policy" "st" {
  count = var.storage.enabled && length(var.storage.rules) > 0 ? 1 : 0

  storage_account_id = azurerm_storage_account.i[0].id

  dynamic "rule" {
    for_each = var.storage.rules

    content {
      name    = rule.value["name"]
      enabled = true
      filters {
        prefix_match = rule.value["prefix_match"]
        blob_types   = ["blockBlob"]
      }
      actions {
        base_blob {
          delete_after_days_since_modification_greater_than = rule.value["delete_after_days"]
        }
      }
    }
  }
}
