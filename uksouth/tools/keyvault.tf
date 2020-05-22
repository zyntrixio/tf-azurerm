resource "azurerm_key_vault" "tools" {
    name = "bink-${azurerm_resource_group.rg.name}"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enabled_for_disk_encryption = true
    tenant_id = data.azurerm_client_config.current.tenant_id
    soft_delete_enabled = false
    purge_protection_enabled = true

    sku_name = "standard"

    tags = var.tags

    lifecycle {
        prevent_destroy = true
    }
}

resource "azurerm_key_vault_access_policy" "devops" {
    for_each = var.devops_objectids

    key_vault_id = azurerm_key_vault.tools.id
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = each.value["object_id"]
    secret_permissions = var.devops_keyvault_secretperms
}

resource "azurerm_user_assigned_identity" "vaultshim" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    name = "vaultshim"
}

resource "azurerm_key_vault_access_policy" "vaultshim" {
    key_vault_id = azurerm_key_vault.tools.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.vaultshim.principal_id

    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}

output "vaultshim" {
    description = "Vault -> KeyVault shim"
    value = {
        resource_id = azurerm_user_assigned_identity.vaultshim.id
        client_id = azurerm_user_assigned_identity.vaultshim.client_id
        principal_id = azurerm_user_assigned_identity.vaultshim.principal_id
    }
}
output "keyvault" {
    description = "Env Specific KeyVault"
    value = {
        name = azurerm_key_vault.tools.name
        id = azurerm_key_vault.tools.id
        url = azurerm_key_vault.tools.vault_uri
    }
}
