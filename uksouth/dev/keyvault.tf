module "kv" {
    source = "../../modules/keyvault"

    name = "uksouth-dev"  # Prefixes it with bink-
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

resource "azurerm_key_vault_access_policy" "fakicorp" {
    key_vault_id = module.kv.keyvault.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.fakicorp.principal_id

    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}

# Allow dev users access to dev keyvault
locals {
    kv_users = {
        MartinMarsh = { object_id = "3c92809d-91a4-456f-a161-a8b9df4c01e1" },
        StewartPerrygrove = { object_id = "c7c13573-de9a-443e-a1a7-cc272cb26e2e" },
    }
}

resource "azurerm_key_vault_access_policy" "kv_access" {
    for_each = local.kv_users

    key_vault_id = module.kv.keyvault.id
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = each.value["object_id"]
    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}
