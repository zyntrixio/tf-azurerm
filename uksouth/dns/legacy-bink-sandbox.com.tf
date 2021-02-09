resource "azurerm_dns_zone" "bink_sandbox_com" {
    name = "bink-sandbox.com"
    resource_group_name = azurerm_resource_group.rg.name
}
