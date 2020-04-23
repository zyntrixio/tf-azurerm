output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

output "firewall_ip" {
    value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}
