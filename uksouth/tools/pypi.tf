resource "azurerm_storage_account" "tools" {
    name = "binktools"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"

    tags = var.tags
}

resource "azurerm_storage_container" "pypi" {
    name = "pypi"
    storage_account_name = azurerm_storage_account.tools.name
    container_access_type = "private"
}
