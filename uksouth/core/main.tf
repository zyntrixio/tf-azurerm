resource "azurerm_resource_group" "rg" {
    name = "uksouth-core"
    location = "uksouth"
}

resource "azurerm_container_registry" "binkcore" {
    name = "binkcore"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "Premium"
    admin_enabled = true
    georeplications {
      location = "ukwest"
    }
}

resource "azurerm_container_registry" "binkext" {
    name = "binkext"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "Premium"
    admin_enabled = true
    georeplications {
      location = "ukwest"
    }
}
