resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
    tags = var.tags
}

provider "azurerm" {
    alias = "core"
}

data "azurerm_subscription" "current" {
}
