resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
    for_each = var.private_dns

    provider = azurerm.core

    name = "${azurerm_virtual_network.vnet.name}-${each.key}"
    resource_group_name = each.value["resource_group_name"]
    private_dns_zone_name = each.value["private_dns_zone_name"]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = each.value["should_register"]
}

