resource "azurerm_resource_group" "rg" {
    name = "uksouth-tableau"
    location = "uksouth"

    tags = var.tags
}
