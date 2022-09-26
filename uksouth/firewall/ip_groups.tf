resource "azurerm_ip_group" "frontdoor_backend_v4" {
    name = "frontdoor_backend_v4"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    lifecycle {
        ignore_changes = [cidrs]  # Updated by external service, terraform should not modify this object
    }
}

resource "azurerm_role_assignment" "frontdoor_backend_v4" {
    scope = azurerm_ip_group.frontdoor_backend_v4.id
    role_definition_name = "Contributor"
    principal_id = "3f8a04a0-2675-48c5-a0df-7d3e0d684e79"  # App Registration: Azure Frontdoor IP Range Updater
}

resource "azurerm_ip_group" "secure_origins_v4" {
    name = "secure_origins_v4"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    cidrs = var.secure_origins
}

resource "azurerm_ip_group" "digital_ocean_checkly_runners_v4" {
    name = "digital_ocean_checkly_runners_v4"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    cidrs = [ "167.172.61.234/32", "167.172.53.20/32" ]
}
