resource "azurerm_log_analytics_workspace" "i" {
  count = var.loganalytics.enabled ? 1 : 0

  name                = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  sku                 = var.loganalytics.sku
  retention_in_days   = var.loganalytics.retention_in_days
}

resource "azurerm_role_assignment" "la_mi" {
  for_each = {
    for k, v in local.identities : k => v
    if contains(v["assigned_to"], "la") && var.loganalytics.enabled
  }

  scope                = azurerm_log_analytics_workspace.i[0].id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "la_iam" {
  for_each = {
    for k, v in var.iam : k => v
    if contains(v["assigned_to"], "la") && var.loganalytics.enabled
  }

  scope                = azurerm_log_analytics_workspace.i[0].id
  role_definition_name = "Reader"
  principal_id         = each.key
}
