locals {
    identity_namespace_map = merge(flatten(([
        for k, v in var.managed_identities : {
            for namespace in v["namespaces"] :
                "${k}_${namespace}" => {
                    identity = k
                    namespace = namespace
                }
        }
    ]))...)
}

resource "azurerm_user_assigned_identity" "i" {
    for_each = var.managed_identities

    name = "${azurerm_resource_group.i.name}-${each.key}"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_federated_identity_credential" "i" {
    for_each = { for k, v in local.identity_namespace_map : k => v if var.kube.enabled}

    name = "${azurerm_resource_group.i.name}-${each.value.identity}-${each.value.namespace}"
    resource_group_name = azurerm_resource_group.i.name
    audience = ["api://AzureADTokenExchange"]
    issuer = azurerm_kubernetes_cluster.i[0].oidc_issuer_url
    parent_id = azurerm_user_assigned_identity.i[each.value.identity].id
    subject = "system:serviceaccount:${each.value.namespace}:${each.value.identity}"
}

resource "azurerm_key_vault_secret" "mi" {
    count = var.keyvault.enabled ? 1 : 0

    name = "infra-managed-identity-details"
    key_vault_id = azurerm_key_vault.i[0].id
    content_type = "application/json"
    value = jsonencode(
        merge(
            {"tenant_id" = data.azurerm_client_config.i.tenant_id},
            {for k, v in azurerm_user_assigned_identity.i : "${replace(k, "-", "_")}_client_id" => v.client_id}
        )
    )
    tags = {
        k8s_secret_name = "azure-identities"
    }

    depends_on = [ azurerm_key_vault_access_policy.iam_su ]
}
