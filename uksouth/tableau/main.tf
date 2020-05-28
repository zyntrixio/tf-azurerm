resource "azurerm_resource_group" "rg" {
    name = "uksouth-tableau"
    location = "uksouth"

    tags = var.tags
}

resource "azurerm_container_registry" "acr" {
    name = "binktableau"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "Basic"
    admin_enabled = true
}

