output "bink-com" {
    value = [azurerm_resource_group.rg.name, azurerm_dns_zone.bink-com.name]
}

output "bink-sh" {
    value = [azurerm_resource_group.rg.name, azurerm_dns_zone.bink-sh.name]
}

output "uksouth-bink-sh" {
    value = [azurerm_resource_group.rg.name, azurerm_private_dns_zone.uksouth-bink-sh.name]
}

output "bink-host" {
    value = [azurerm_resource_group.rg.name, azurerm_dns_zone.bink-host.name]
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

output "public_dns" {
    value = {
        "bink_sh" = {
            resource_group_name = azurerm_resource_group.rg.name
            dns_zone_name = azurerm_dns_zone.bink-sh.name
        }
    }
}
