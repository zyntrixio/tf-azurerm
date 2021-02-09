resource "azurerm_dns_zone" "bink_co_uk" {
    name = "bink.co.uk"
    resource_group_name = azurerm_resource_group.rg.name
}
