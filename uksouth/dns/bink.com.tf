resource "azurerm_dns_zone" "bink-com" {
  name = "bink.com"
  resource_group_name = azurerm_resource_group.rg.name
}
