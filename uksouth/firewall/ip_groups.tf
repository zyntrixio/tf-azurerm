resource "azurerm_ip_group" "frontdoor_ips" {
    name = "frontdoor_ips"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# This didn't work, figure it out later, assigned via the portal. Come back to this one @cpressland
# resource "azurerm_role_assignment" "frontdoor_ips" {
#     scope = azurerm_ip_group.frontdoor_ips.id
#     role_definition_name = "Contributor"
#     principal_id = "b26a9d99-0fcb-471e-aaab-9d266776b1e7"  # App Registration: Azure Frontdoor IP Range Updater
# }

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
