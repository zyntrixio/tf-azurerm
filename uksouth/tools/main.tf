resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = "uksouth"

    tags = var.tags
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "prometheus" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    name = "prometheus"
}
