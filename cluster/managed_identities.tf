resource "azurerm_user_assigned_identity" "i" {
    for_each = var.managed_identities

    name = "${azurerm_resource_group.i.name}-${each.key}"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_federated_identity_credential" "i" {
    for_each = { for k, v in var.managed_identities : k => v if var.kube.enabled }

    name = "${azurerm_resource_group.i.name}-${each.key}"
    resource_group_name = azurerm_resource_group.i.name
    audience = ["api://AzureADTokenExchange"]
    issuer = azurerm_kubernetes_cluster.i[0].oidc_issuer_url
    parent_id = azurerm_user_assigned_identity.i[each.key].id
    subject = "system:serviceaccount:${each.value.namespace}:${each.key}"
}
