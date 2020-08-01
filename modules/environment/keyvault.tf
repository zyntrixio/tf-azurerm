data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "infra" {
    name = "bink-${azurerm_resource_group.rg.name}-inf"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags = var.tags

    sku_name = "standard"
    # All don't need much accidental delete protection as TF populates this KV
    enabled_for_disk_encryption = false
    tenant_id = data.azurerm_client_config.current.tenant_id
    soft_delete_enabled = false
    purge_protection_enabled = false

    access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = "aac28b59-8ac3-4443-bccc-3fb820165a08"
        secret_permissions = [
            "backup",
            "delete",
            "get",
            "list",
            "purge",
            "recover",
            "restore",
            "set",
        ]
    }
}

# Used to sync KeyVault postgres/redis/... to the cluster secrets
resource "azurerm_user_assigned_identity" "infra_sync" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    name = "kv-${azurerm_resource_group.rg.name}-infra-sync"
}

# TODO export resource and client id
resource "azurerm_key_vault_access_policy" "infra_sync" {
    key_vault_id = azurerm_key_vault.infra.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.infra_sync.principal_id

    secret_permissions = [
        "get",
        "list"
    ]
}

resource "azurerm_key_vault" "common" {
    name = "bink-${azurerm_resource_group.rg.name}-com"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags = var.tags

    sku_name = "standard"
    enabled_for_disk_encryption = false
    tenant_id = data.azurerm_client_config.current.tenant_id
    soft_delete_enabled = false
    purge_protection_enabled = false

    access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = "aac28b59-8ac3-4443-bccc-3fb820165a08"
        secret_permissions = [
            "backup",
            "delete",
            "get",
            "list",
            "purge",
            "recover",
            "restore",
            "set",
        ]
    }

    dynamic "access_policy" {
        for_each = [for i in var.keyvault_users : {
            id = i["object_id"]
        }]

        content {
            tenant_id = data.azurerm_client_config.current.tenant_id
            object_id = access_policy.value.id
            secret_permissions = ["get", "list", "set", "delete"]
        }
    }
    # lifecycle {
    #     prevent_destroy = true
    # }
}

resource "azurerm_user_assigned_identity" "fakicorp" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    name = "kv-${azurerm_resource_group.rg.name}-fakicorp"
}

# TODO export resource and client id
resource "azurerm_key_vault_access_policy" "fakicorp" {
    key_vault_id = azurerm_key_vault.common.id

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.fakicorp.principal_id

    secret_permissions = [
        "get",
        "list",
        "set",
        "delete"
    ]
}
