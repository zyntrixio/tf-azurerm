output "ip_address" {
    value = cidrhost(azurerm_subnet.subnet.address_prefixes[0], 4)
}
