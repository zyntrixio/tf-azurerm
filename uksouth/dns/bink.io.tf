resource "azurerm_dns_zone" "bink-io" {
    name = "bink.io"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "uksouth-bink-io" {
    name = "uksouth.bink.io"
    resource_group_name = azurerm_resource_group.rg.name
}
