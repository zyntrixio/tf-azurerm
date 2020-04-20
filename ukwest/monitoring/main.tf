resource "azurerm_resource_group" "rg" {
    name = "ukwest-monitoring"
    location = "ukwest"

    tags = var.tags
}
