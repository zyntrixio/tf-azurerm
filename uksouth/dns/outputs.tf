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
