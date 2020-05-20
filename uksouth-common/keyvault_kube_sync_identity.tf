resource "azurerm_user_assigned_identity" "keyvault2kube" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    name = "keyvault2kube"
}

resource "azurerm_key_vault_access_policy" "keyvault2kube" {
    key_vault_id = azurerm_key_vault.common.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.keyvault2kube.principal_id

    secret_permissions = [
        "get",
        "list"
    ]
}

output "keyvault2kube_identity" {
    description = "KeyVault2"
    value = {
        resource_id = azurerm_user_assigned_identity.keyvault2kube.id
        client_id = azurerm_user_assigned_identity.keyvault2kube.client_id
        principal_id = azurerm_user_assigned_identity.keyvault2kube.principal_id
    }
}
