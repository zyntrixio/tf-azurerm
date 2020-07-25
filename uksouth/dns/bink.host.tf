resource "azurerm_dns_zone" "bink-host" {
    name = "bink.host"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "uksouth-bink-host" {
    name = "uksouth.bink.host"
    resource_group_name = azurerm_resource_group.rg.name
}
