output "peering" {
    value = {
        vnet_id = azurerm_virtual_network.i.id
        vnet_name = azurerm_virtual_network.i.name
        resource_group_name = azurerm_resource_group.i.name
    }
}
