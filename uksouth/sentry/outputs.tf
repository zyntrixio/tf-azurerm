output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

output "ip_address" {
    value = azurerm_network_interface.nic.private_ip_address
}
