output "bink-com" {
    value = [azurerm_resource_group.rg.name, azurerm_dns_zone.bink-com.name, azurerm_dns_zone.bink-com.id]
}

output "bink-sh" {
    value = [azurerm_resource_group.rg.name, azurerm_dns_zone.bink-sh.name, azurerm_dns_zone.bink-sh.id]
}

output "bink-host" {
    value = [azurerm_resource_group.rg.name, azurerm_dns_zone.bink-host.name, azurerm_dns_zone.bink-host.id]
}

output "uksouth-bink-host" {
    value = [azurerm_resource_group.rg.name, azurerm_private_dns_zone.uksouth-bink-host.name, azurerm_private_dns_zone.uksouth-bink-host.id]
}

output "private_dns" {
    value = {
        "uksouth_host" = {
            resource_group_name = azurerm_resource_group.rg.name
            private_dns_zone_name = azurerm_private_dns_zone.uksouth-bink-host.name
            should_register = true
        }
    }
}

output "public_dns" {
    value = {
        "bink_sh" = {
            resource_group_name = azurerm_resource_group.rg.name
            dns_zone_name = azurerm_dns_zone.bink-sh.name
        },
        "bink_com" = {
            resource_group_name = azurerm_resource_group.rg.name
            dns_zone_name = azurerm_dns_zone.bink-com.name
        }
    }
}
