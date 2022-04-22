output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
    value = azurerm_virtual_network.vnet.name
}

output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}

output "firewall_ip" {
    value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

output "firewall_name" {
    value = azurerm_firewall.firewall.name
}

output "public_ips" {
    value = azurerm_public_ip.pips
}

output "peering" {
    value = {
        vnet_id = azurerm_virtual_network.vnet.id
        vnet_name = azurerm_virtual_network.vnet.name
        rg_name = azurerm_resource_group.rg.name
        firewall_name = azurerm_firewall.firewall.name
        firewall_ip = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
    }
}
