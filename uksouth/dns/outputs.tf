output "bink-com" {
    value = azurerm_dns_zone.bink-com.id
}

output "bink-sh" {
    value = azurerm_dns_zone.bink-sh.id
}

output "uksouth-bink-sh" {
    value = [azurerm_resource_group.rg.name, azurerm_private_dns_zone.uksouth-bink-sh.name]
}

output "bink-host" {
    value = azurerm_dns_zone.bink-host.id
}

output "uksouth-bink-host" {
    value = [azurerm_resource_group.rg.name, azurerm_private_dns_zone.uksouth-bink-host.name]
}

output "private_dns" {
    value = {
        "uksouth_sh" = {
            resource_group_name = azurerm_resource_group.rg.name
            private_dns_zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
            should_register = false
        }
        "uksouth_host" = {
            resource_group_name = azurerm_resource_group.rg.name
            private_dns_zone_name = azurerm_private_dns_zone.uksouth-bink-host.name
            should_register = true
        }
    }
}
