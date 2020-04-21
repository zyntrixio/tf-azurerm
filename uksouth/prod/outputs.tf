output "subnet_cidrs" {
    value = zipmap(var.subnet_names, var.subnet_address_prefixes)
}

output "subnet_ids" {
    value = zipmap(var.subnet_names, azurerm_subnet.subnet.*.id)
}
