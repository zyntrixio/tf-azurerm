resource "azurerm_key_vault" "common" {
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

    key_vault_id = azurerm_key_vault.common.id
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = each.value["object_id"]
    secret_permissions = var.devops_keyvault_secretperms
}

output "keyvault" {
    description = "Common KeyVault"
    value = {
        name = azurerm_key_vault.common.name
        id = azurerm_key_vault.common.id
        url = azurerm_key_vault.common.vault_uri
    }
}
