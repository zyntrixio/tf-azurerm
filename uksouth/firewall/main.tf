resource "azurerm_resource_group" "rg" {
    name = "uksouth-firewall"
    location = "uksouth"

    tags = var.tags
}
