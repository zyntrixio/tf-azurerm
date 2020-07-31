data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
    for_each = var.keyvault_config

    name = each.value["name"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags = var.tags

    sku_name = lookup(each.value, "sku_name", "standard")
    enabled_for_disk_encryption = lookup(each.value, "enabled_for_disk_encryption", true)
    tenant_id = data.azurerm_client_config.current.tenant_id
    soft_delete_enabled = lookup(each.value, "soft_delete_enabled", false)
    purge_protection_enabled = lookup(each.value, "purge_protection_enabled", true)

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
            secret_permissions = [ "get", "list", "set", "delete" ]
        }
    }
    # lifecycle {
    #     prevent_destroy = true
    # }
}
