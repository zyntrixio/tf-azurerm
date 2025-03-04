locals {
  default_identities = {
    cert-manager               = { namespaces = ["cert-manager"], assigned_to = [] }
    kv-to-kube                 = { namespaces = ["kv-to-kube"], assigned_to = ["kv_ro"] }
    image-reflector-controller = { namespaces = ["flux-system"], assigned_to = [] }
    nightcity                  = { namespaces = ["devops"], assigned_to = ["kv_ro", "st_rw", "sftp_rw"] }
    pytest                     = { namespaces = [], assigned_to = ["kv_ro"] }
    snowboard                  = { namespaces = ["data"], assigned_to = ["kv_ro"] }
    nextdns-invoices           = { namespaces = ["devops"], assigned_to = ["kv_ro"] }
  }
  identities = merge(local.default_identities, var.managed_identities)
  identity_namespace_map = merge(([
    for k, v in local.identities : {
      for namespace in v["namespaces"] :
      "${k}_${namespace}" => {
        identity  = k
        namespace = namespace
      }
    }
  ])...)
}

resource "azurerm_user_assigned_identity" "i" {
  for_each = local.identities

  name                = "${azurerm_resource_group.i.name}-${each.key}"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_role_assignment" "mi_mi" {
  for_each = {
    for k, v in local.identities : k => v
    if contains(v["assigned_to"], "mi")
  }

  scope                = azurerm_resource_group.i.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_federated_identity_credential" "i" {
  for_each = { for k, v in local.identity_namespace_map : k => v }

  name                = "${azurerm_resource_group.i.name}-${each.value.identity}-${each.value.namespace}"
  resource_group_name = azurerm_resource_group.i.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.i.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.i[each.value.identity].id
  subject             = "system:serviceaccount:${each.value.namespace}:${each.value.identity}"
}

resource "azurerm_key_vault_secret" "mi" {
  name         = "infra-managed-identity-details"
  key_vault_id = azurerm_key_vault.i.id
  content_type = "application/json"
  value = jsonencode(
    merge(
      { "tenant_id" = data.azurerm_client_config.i.tenant_id },
      { "oidc_issuer_url" = azurerm_kubernetes_cluster.i.oidc_issuer_url },
      { for k, v in azurerm_user_assigned_identity.i : "${replace(k, "-", "_")}_client_id" => v.client_id }
    )
  )
  tags = {
    kube_secret_name = "azure-identities"
  }

  depends_on = [azurerm_key_vault_access_policy.iam_su]
}

resource "azuread_directory_role_assignment" "nightcity" {
  role_id             = "5d6b6bb7-de71-4623-b4af-96380a352509"
  principal_object_id = azurerm_user_assigned_identity.i["nightcity"].principal_id
}
