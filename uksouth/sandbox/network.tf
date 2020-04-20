resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.address_space]

    tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
    count = length(var.subnet_address_prefixes)
    name = format("${var.environment}-subnet-%02d-nsg", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags
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
        next_hop_in_ip_address = "192.168.0.4"
    }

    tags = var.tags
}

variable service_endpoint {
    default = [
        "Microsoft.Storage",
        "Microsoft.ContainerRegistry",
        "Microsoft.Sql",
    ]
}

resource "azurerm_subnet" "subnet" {
    count = length(var.subnet_address_prefixes)
    name = format("subnet-%02d", count.index + 1)
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefix = element(var.subnet_address_prefixes, count.index)
    service_endpoints = count.index == 0 ? var.service_endpoint : []
}

resource "azurerm_network_watcher_flow_log" "flow_logs" {
    count = length(var.subnet_address_prefixes)
    network_watcher_name = "NetworkWatcher_uksouth"
    resource_group_name = "NetworkWatcherRG"

    network_security_group_id = element(azurerm_network_security_group.nsg.*.id, count.index)
    storage_account_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/stega/providers/Microsoft.Storage/storageAccounts/binkstegansgflowlogs"
    enabled = false
    version = 2

    retention_policy {
        enabled = true
        days = 3
    }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    count = length(var.subnet_address_prefixes)
    subnet_id = element(azurerm_subnet.subnet.*.id, count.index)
    network_security_group_id = element(azurerm_network_security_group.nsg.*.id, count.index)
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
    count = length(var.subnet_address_prefixes)
    subnet_id = element(azurerm_subnet.subnet.*.id, count.index)
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_virtual_network_peering" "peer" {
    name = "local-to-firewall"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-firewall/providers/Microsoft.Network/virtualNetworks/firewall-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_lb" "lb" {
    name = "${var.environment}-lb"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"

    frontend_ip_configuration {
        name = "subnet-01"
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.subnet_address_prefixes[0], 4)
        subnet_id = azurerm_subnet.subnet.0.id
    }
    frontend_ip_configuration {
        name = "subnet-02"
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.subnet_address_prefixes[1], 4)
        subnet_id = azurerm_subnet.subnet.1.id
    }

    tags = {
        environment = var.environment
    }
}

resource "azurerm_lb_backend_address_pool" "pools" {
    count = length(var.subnet_address_prefixes)
    name = format("subnet-%02d", count.index + 1)
    loadbalancer_id = azurerm_lb.lb.id
    resource_group_name = azurerm_resource_group.rg.name
}
