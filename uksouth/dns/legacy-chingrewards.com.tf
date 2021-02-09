resource "azurerm_dns_zone" "chingrewards_com" {
    name = "chingrewards.com"
    resource_group_name = azurerm_resource_group.rg.name
}
