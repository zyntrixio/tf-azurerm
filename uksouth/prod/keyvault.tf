module "kv_preprod" {
    source = "../../modules/keyvault"

    name = "uksouth-preprod"  # Prefixes it with bink-
    rg_name = azurerm_resource_group.rg.name  # has name as well as we'll have multiple keyvaults per cluster
    rg_location = azurerm_resource_group.rg.location
    tags = var.tags
}
module "kv_prod" {
    source = "../../modules/keyvault"

    name = "uksouth-prod"  # Prefixes it with bink-
    rg_name = azurerm_resource_group.rg.name  # has name as well as we'll have multiple keyvaults per cluster
    rg_location = azurerm_resource_group.rg.location
    tags = var.tags
}

# For Fakicorp Vault API
resource "azurerm_user_assigned_identity" "fakicorp" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    name = "fakicorp"
}

resource "azurerm_key_vault_access_policy" "fakicorp_preprod" {
    key_vault_id = module.kv_preprod.keyvault.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.fakicorp.principal_id

    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}

resource "azurerm_key_vault_access_policy" "fakicorp_prod" {
    key_vault_id = module.kv_prod.keyvault.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.fakicorp.principal_id

    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}
