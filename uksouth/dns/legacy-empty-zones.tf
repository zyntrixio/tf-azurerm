# CBA to do for_each
resource "azurerm_dns_zone" "bink_sandbox_com" {
    name = "bink-sandbox.com"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_zone" "bink_co_uk" {
    name = "bink.co.uk"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_zone" "chingrewards_com" {
    name = "chingrewards.com"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_zone" "loyaltyangels_co_uk" {
    name = "loyaltyangels.co.uk"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_zone" "mygravity_co_uk" {
    name = "mygravity.co.uk"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_zone" "mygravity_info" {
    name = "mygravity.info"
    resource_group_name = azurerm_resource_group.rg.name
}
