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

    # lifecycle {
    #     prevent_destroy = true
    # }
}
