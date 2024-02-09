resource "random_string" "kv" {
  length      = 4
  upper       = false
  special     = false
  min_numeric = 2
}

resource "azurerm_key_vault" "i" {
  name                = "${azurerm_resource_group.i.name}-${random_string.kv.result}"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name

  sku_name                    = "premium"
  purge_protection_enabled    = false
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.i.tenant_id
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = "loganalytics"
  target_resource_id         = azurerm_key_vault.i.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.i.id

  enabled_log { category = "AuditEvent" }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

resource "azurerm_role_assignment" "kv_mi_ro" {
  for_each = { for k, v in local.identities : k => v if contains(v["assigned_to"], "kv_ro") }

  scope                = azurerm_key_vault.i.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "kv_mi_rw" {
  for_each = { for k, v in local.identities : k => v if contains(v["assigned_to"], "kv_su") || contains(v["assigned_to"], "kv_rw") }

  scope                = azurerm_key_vault.i.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "kv_iam_ro" {
  for_each = { for k, v in var.iam : k => v if contains(v["assigned_to"], "kv_ro") }

  scope                = azurerm_key_vault.i.id
  role_definition_name = "Reader"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "kv_iam_rw" {
  for_each = { for k, v in var.iam : k => v if contains(v["assigned_to"], "kv_su") || contains(v["assigned_to"], "kv_rw") }

  scope                = azurerm_key_vault.i.id
  role_definition_name = "Contributor"
  principal_id         = each.key
}

resource "azurerm_key_vault_access_policy" "mi_ro" {
  for_each = { for k, v in local.identities : k => v if contains(v["assigned_to"], "kv_ro") }

  key_vault_id = azurerm_key_vault.i.id
  tenant_id    = data.azurerm_client_config.i.tenant_id
  object_id    = azurerm_user_assigned_identity.i[each.key].principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "mi_rw" {
  for_each = { for k, v in local.identities : k => v if contains(v["assigned_to"], "kv_rw") }

  key_vault_id = azurerm_key_vault.i.id
  tenant_id    = data.azurerm_client_config.i.tenant_id
  object_id    = azurerm_user_assigned_identity.i[each.key].principal_id

  secret_permissions = ["Get", "List", "Set", "Delete"]
}

resource "azurerm_key_vault_access_policy" "iam_ro" {
  for_each = { for k, v in var.iam : k => v if contains(v["assigned_to"], "kv_ro") }

  key_vault_id = azurerm_key_vault.i.id
  tenant_id    = data.azurerm_client_config.i.tenant_id
  object_id    = each.key

  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "iam_rw" {
  for_each = { for k, v in var.iam : k => v if contains(v["assigned_to"], "kv_rw") }

  key_vault_id = azurerm_key_vault.i.id
  tenant_id    = data.azurerm_client_config.i.tenant_id
  object_id    = each.key

  secret_permissions = ["Get", "List", "Set"]
}

resource "azurerm_key_vault_access_policy" "iam_su" {
  for_each = { for k, v in var.iam : k => v if contains(v["assigned_to"], "kv_su") }

  key_vault_id = azurerm_key_vault.i.id
  tenant_id    = data.azurerm_client_config.i.tenant_id
  object_id    = each.key

  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Purge", "Release",
    "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Rotate", "GetRotationPolicy", "SetRotationPolicy",
  ]
}

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.i.id
  tenant_id    = data.azurerm_client_config.i.tenant_id
  object_id    = azurerm_kubernetes_cluster.i.kubelet_identity[0].object_id

  secret_permissions      = ["Get"]
  certificate_permissions = ["Get"]
  key_permissions         = ["Get"]
}

resource "azurerm_key_vault_secret" "kv" {
  name         = "infra-keyvault-connection-details"
  key_vault_id = azurerm_key_vault.i.id
  content_type = "application/json"
  value = jsonencode({
    "url"           = azurerm_key_vault.i.vault_uri,
    "keyvault_name" = azurerm_key_vault.i.name,
  })
  tags = {
    kube_secret_name = "azure-keyvault"
  }

  depends_on = [azurerm_key_vault_access_policy.iam_su]
}
