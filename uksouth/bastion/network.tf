resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.ip_range]

    tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
    name = "${var.environment}-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

    security_rule {
        name = "AllowSSH"
        description = "SSH Access"
        access = "Allow"
        priority = 500
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefix = "*"  # This is limited by Azure Firewall
        source_port_range = "*"
        destination_address_prefix = var.ip_range
        destination_port_ranges = [22]
    }

    security_rule {
        name = "BlockEverything"
        description = "Default Block All Rule"
        access = "Deny"
        priority = 4096
        direction = "Inbound"
        protocol = "*"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "*"
    }
}

resource "azurerm_route_table" "rt" {
    name = "${var.environment}-routes"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    disable_bgp_route_propagation = true

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.firewall_route_ip
    }

    tags = var.tags
}

resource "azurerm_subnet" "subnet0" {
    name = "subnet0"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefix = var.ip_range
}

resource "azurerm_network_watcher_flow_log" "flow_logs" {
    network_watcher_name = "NetworkWatcher_uksouth"
    resource_group_name = "NetworkWatcherRG"

    network_security_group_id = azurerm_network_security_group.nsg.id
    storage_account_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/stega/providers/Microsoft.Storage/storageAccounts/binkstegansgflowlogs"
    enabled = var.flow_logs_enabled
    version = 2

    retention_policy {
        enabled = true
        days = 3
    }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    subnet_id = azurerm_subnet.subnet0.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
    subnet_id = azurerm_subnet.subnet0.id
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_virtual_network_peering" "peer" {
    name = "local-to-firewall"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = var.firewall_vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}
