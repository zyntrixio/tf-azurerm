output "bink-com" {
    value = azurerm_dns_zone.bink-com.id
}

output "bink-sh" {
    value = azurerm_dns_zone.bink-sh.id
}

output "bink-io" {
    value = azurerm_dns_zone.bink-io.id
}

output "uksouth-bink-io" {
    value = [azurerm_resource_group.rg.name, azurerm_private_dns_zone.uksouth-bink-io.name]
}
