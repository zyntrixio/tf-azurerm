resource "azurerm_resource_group" "rg" {
    name = "uksouth-staging"
    location = "uksouth"

    tags = var.tags
}
