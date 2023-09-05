resource "random_string" "ac" {
    length = 4
    upper = false
    special = false
    min_numeric = 2
}

resource "azurerm_app_configuration" "i" {
    name = "${azurerm_resource_group.i.name}-${random_string.ac.result}"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    sku = "standard"
    public_network_access = "Enabled"
}

resource "azurerm_monitor_diagnostic_setting" "ac" {
    count = var.loganalytics.enabled ? 1 : 0

    name = "loganalytics"
    target_resource_id = azurerm_app_configuration.i.id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

    enabled_log { category = "HttpRequest" }
    metric {
        category = "AllMetrics"
        enabled = false
    }
}

resource "azurerm_role_assignment" "ac_iam_ro" {
    for_each = {
        for k, v in var.iam : k => v
             if contains(v["assigned_to"], "ac_ro")
    }

    scope = azurerm_app_configuration.i.id
    role_definition_name = "Reader"
    principal_id = each.key
}

resource "azurerm_role_assignment" "ac_iam_rw" {
    for_each = {
        for k, v in var.iam : k => v
             if contains(v["assigned_to"], "ac_su") ||
                contains(v["assigned_to"], "ac_rw")
    }

    scope = azurerm_app_configuration.i.id
    role_definition_name = "Contributor"
    principal_id = each.key
}

resource "azurerm_key_vault_secret" "ac" {
    count = var.keyvault.enabled ? 1 : 0

    name = "infra-app-config-connection-details"
    key_vault_id = azurerm_key_vault.i[0].id
    content_type = "application/json"
    value = jsonencode({
        "primary_write_connection_string" = azurerm_app_configuration.i.primary_write_key[0].connection_string
        "primary_read_connection_string" = azurerm_app_configuration.i.primary_read_key[0].connection_string
        "secondary_write_connection_string" = azurerm_app_configuration.i.secondary_write_key[0].connection_string
        "secondary_read_connection_string" = azurerm_app_configuration.i.secondary_read_key[0].connection_string
    })
    tags = {
        k8s_secret_name = "azure-app-config"
    }

    depends_on = [ azurerm_key_vault_access_policy.iam_su ]
}
