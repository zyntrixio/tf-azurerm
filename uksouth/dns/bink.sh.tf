resource "azurerm_dns_zone" "bink-sh" {
    name = "bink.sh"
    resource_group_name = azurerm_resource_group.rg.name
}
