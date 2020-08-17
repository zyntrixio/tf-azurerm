# Source peers
resource "azurerm_virtual_network_peering" "peer" {
    for_each = var.peers

    name = "local-to-${each.key}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = each.value["vnet_id"]
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

# Remote peers
resource "azurerm_virtual_network_peering" "remote_peer" {
    for_each = var.peers

    provider = azurerm.core

    name = "local-to-${azurerm_resource_group.rg.name}"
    resource_group_name = each.value["resource_group_name"]
    virtual_network_name = each.value["vnet_name"]
    remote_virtual_network_id = azurerm_virtual_network.vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}
