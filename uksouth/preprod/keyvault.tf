module "kv_preprod" {
    source = "../../modules/keyvault"

    name = "uksouth-preprod"  # Prefixes it with bink-
    rg_name = azurerm_resource_group.rg.name  # has name as well as we'll have multiple keyvaults per cluster
    rg_location = azurerm_resource_group.rg.location
    eventhub_name = "azurekeyvault"
    eventhub_auth = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    tags = var.tags
}

resource "azurerm_user_assigned_identity" "fakicorp" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    name = "fakicorp"
}

resource "azurerm_key_vault_access_policy" "fakicorp" {
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

locals {
    kv_users = {
        ChristianPrior = { object_id = "ae282437-d730-4342-8914-c936e8289cdc" },
        MartinMarsh = { object_id = "3c92809d-91a4-456f-a161-a8b9df4c01e1" },
    }
}

resource "azurerm_key_vault_access_policy" "kv_access" {
    for_each = local.kv_users

    key_vault_id = module.kv_preprod.keyvault.id
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = each.value["object_id"]
    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}
