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

output "public_ip_prefix" {
    value = azurerm_public_ip_prefix.prefix.ip_prefix
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

output "config" {
    value = {
        resource_group = {
            name = azurerm_resource_group.rg.name
        }
        virtual_network = {
            name = azurerm_virtual_network.vnet.name
            id = azurerm_virtual_network.vnet.id
        }
        firewall = {
            name = azurerm_firewall.firewall.name
            ip = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
        }
    }
}

output "ip_groups" {
    value = {
        office = azurerm_ip_group.office_ips.id
        devops = azurerm_ip_group.devops_ips.id
        frontdoor = azurerm_ip_group.frontdoor_ips.id
    }
}
