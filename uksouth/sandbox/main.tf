resource "azurerm_resource_group" "rg" {
    name = "uksouth-sandbox"
    location = "uksouth"

    tags = var.tags
}

data "azurerm_client_config" "current" {}
