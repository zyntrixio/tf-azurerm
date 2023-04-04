resource "random_string" "kv" {
    length = 4
    upper = false
    special = false
    min_numeric = 2
}

resource "azurerm_key_vault" "i" {
    count = var.keyvault.enabled ? 1 : 0

    name = "${azurerm_resource_group.i.name}-${random_string.kv.result}"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name

    sku_name = "premium"
    purge_protection_enabled = false
    enabled_for_disk_encryption = false
    tenant_id = data.azurerm_client_config.i.tenant_id
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
    count = var.keyvault.enabled && var.loganalytics.enabled ? 1 : 0

    name = "loganalytics"
    target_resource_id = azurerm_key_vault.i[0].id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

    enabled_log { category = "AuditEvent" }
    metric {
        category = "AllMetrics"
        enabled = false
    }
}

resource "azurerm_role_assignment" "kv" {
    for_each = {
        for k, v in var.managed_identities : k => v
            if contains(v["assigned_to"], "keyvault_rw") || contains(v["assigned_to"], "keyvault_ro")
                && var.keyvault.enabled
    }

    scope = azurerm_key_vault.i[0].id
    role_definition_name = "Reader"
    principal_id = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_key_vault_access_policy" "mi_ro" {
    for_each = {
        for k, v in var.managed_identities : k => v
            if contains(v["assigned_to"], "keyvault_ro") && var.keyvault.enabled
    }

    key_vault_id = azurerm_key_vault.i[0].id
    tenant_id = data.azurerm_client_config.i.tenant_id
    object_id = azurerm_user_assigned_identity.i[each.key].principal_id

    secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "mi_rw" {
    for_each = {
        for k, v in var.managed_identities : k => v
            if contains(v["assigned_to"], "keyvault_rw") && var.keyvault.enabled
    }

    key_vault_id = azurerm_key_vault.i[0].id
    tenant_id = data.azurerm_client_config.i.tenant_id
    object_id = azurerm_user_assigned_identity.i[each.key].principal_id

    secret_permissions = ["Get", "List", "Set", "Delete"]
}

resource "azurerm_key_vault_access_policy" "aks" {
    count = var.keyvault.enabled && var.kube.enabled ? 1 : 0

    key_vault_id = azurerm_key_vault.i[0].id
    tenant_id = data.azurerm_client_config.i.tenant_id
    object_id = azurerm_kubernetes_cluster.i[0].kubelet_identity[0].object_id

    secret_permissions = ["Get"]
    certificate_permissions = ["Get"]
    key_permissions = ["Get"]
}

resource "azurerm_key_vault_access_policy" "devops" {
    count = var.keyvault.enabled ? 1 : 0

    key_vault_id = azurerm_key_vault.i[0].id
    tenant_id = data.azurerm_client_config.i.tenant_id
    object_id = "aac28b59-8ac3-4443-bccc-3fb820165a08"

    secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}
