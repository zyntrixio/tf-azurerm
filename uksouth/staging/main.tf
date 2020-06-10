resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = "uksouth"

    tags = var.tags
}

data "azurerm_client_config" "current" {}
