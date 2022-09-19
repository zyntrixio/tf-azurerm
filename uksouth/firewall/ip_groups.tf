resource "azurerm_ip_group" "frontdoor_ips" {
    name = "frontdoor_ips"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_ip_group" "office_ips" {
    name = "office_ips"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_ip_group" "devops_ips" {
    name = "devops_ips"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}
