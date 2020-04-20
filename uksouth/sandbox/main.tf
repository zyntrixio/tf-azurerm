resource "azurerm_resource_group" "rg" {
    name = "uksouth-sandbox"
    location = "uksouth"

    tags = var.tags
}
