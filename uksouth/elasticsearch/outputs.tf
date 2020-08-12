output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
    value = azurerm_virtual_network.vnet.name
}

output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}
