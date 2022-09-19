resource "azurerm_ip_group" "frontdoor_ips" {
    name = "frontdoor_ips"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "frontdoor_ips" {
    scope = azurerm_ip_group.frontdoor_ips.id
    role_definition_name = "Contributor"
    principal_id = "3f8a04a0-2675-48c5-a0df-7d3e0d684e79"  # App Registration: Azure Frontdoor IP Range Updater
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
