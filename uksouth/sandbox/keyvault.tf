module "kv_sandbox_sit" {
    source = "../../modules/keyvault"

    name = "uksouth-sit"  # Prefixes it with bink-
    rg_name = azurerm_resource_group.rg.name  # has name as well as we'll have multiple keyvaults per cluster
    rg_location = azurerm_resource_group.rg.location
    eventhub_name = "azurekeyvault"
    eventhub_auth = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    tags = var.tags
}
module "kv_sandbox_oat" {
    source = "../../modules/keyvault"

    name = "uksouth-oat"  # Prefixes it with bink-
    rg_name = azurerm_resource_group.rg.name  # has name as well as we'll have multiple keyvaults per cluster
    rg_location = azurerm_resource_group.rg.location
    eventhub_name = "azurekeyvault"
    eventhub_auth = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    tags = var.tags
}

module "kv_sandbox_perf" {
    source = "../../modules/keyvault"

    name = "uksouth-perf"  # Prefixes it with bink-
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

resource "azurerm_key_vault_access_policy" "fakicorp_sit" {
    key_vault_id = module.kv_sandbox_sit.keyvault.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.fakicorp.principal_id

    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}

resource "azurerm_key_vault_access_policy" "fakicorp_oat" {
    key_vault_id = module.kv_sandbox_oat.keyvault.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.fakicorp.principal_id

    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}

resource "azurerm_key_vault_access_policy" "fakicorp_perf" {
    key_vault_id = module.kv_sandbox_perf.keyvault.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.fakicorp.principal_id

    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}
