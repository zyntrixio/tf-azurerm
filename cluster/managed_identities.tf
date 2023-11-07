locals {
    default_identities = {
        kv-to-kube = { namespaces = ["kv-to-kube"], assigned_to = ["kv_ro"] }
        cert-manager = { namespaces = ["cert-manager"], assigned_to = [] }
    }
    identities = merge(local.default_identities, var.managed_identities)
    identity_namespace_map = merge(([
        for k, v in local.identities : {
            for namespace in v["namespaces"] :
                "${k}_${namespace}" => {
                    identity = k
                    namespace = namespace
                }
        }
    ])...)
}

resource "azurerm_user_assigned_identity" "i" {
    for_each = local.identities

    name = "${azurerm_resource_group.i.name}-${each.key}"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_role_assignment" "mi_mi" {
    for_each = {
        for k, v in local.identities : k => v
            if contains(v["assigned_to"], "mi")
    }

    scope = azurerm_resource_group.i.id
    role_definition_name = "Owner"
    principal_id = azurerm_user_assigned_identity.i[each.key].principal_id
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
    count = var.keyvault.enabled && var.kube.enabled ? 1 : 0

    name = "infra-managed-identity-details"
    key_vault_id = azurerm_key_vault.i[0].id
    content_type = "application/json"
    value = jsonencode(
        merge(
            {"tenant_id" = data.azurerm_client_config.i.tenant_id},
            {"oidc_issuer_url" = azurerm_kubernetes_cluster.i[0].oidc_issuer_url},
            {for k, v in azurerm_user_assigned_identity.i : "${replace(k, "-", "_")}_client_id" => v.client_id}
        )
    )
    tags = {
        kube_secret_name = "azure-identities"
    }

    depends_on = [ azurerm_key_vault_access_policy.iam_su ]
}
