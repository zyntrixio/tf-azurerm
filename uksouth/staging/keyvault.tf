module "kv" {
    source = "../../modules/keyvault"

    name = "uksouth-staging"  # Prefixes it with bink-
    rg_name = azurerm_resource_group.rg.name  # has name as well as we'll have multiple keyvaults per cluster
    rg_location = azurerm_resource_group.rg.location
    eventhub_name = "azurekeyvault"
    eventhub_auth = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
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

locals {
    kv_users = {
        Backend = { object_id = "219194f6-b186-4146-9be7-34b731e19001" },
        LocalDev = { object_id = "a43dcb6e-7c82-4503-89c2-0bd9029bba3d" },
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
