resource "azurerm_storage_account" "storage" {
    for_each = var.storage_config

    name = each.value["name"]
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    tags = var.tags

    account_tier = lookup(each.value, "account_tier", "Standard")
    account_replication_type = lookup(each.value, "account_replication_type", "ZRS")
}
