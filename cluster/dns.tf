resource "azurerm_role_assignment" "dns" {
  scope                = var.dns.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.i["cert-manager"].principal_id
}
