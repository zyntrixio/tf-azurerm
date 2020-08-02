resource "azurerm_virtual_network" "vnet" {
    name = "${azurerm_resource_group.rg.name}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.vnet_cidr]
    tags = var.tags
}

resource "azurerm_subnet" "worker" {
    name = "worker"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [
        cidrsubnet(var.vnet_cidr, 2, 0)
    ]
    service_endpoints = [
        "Microsoft.Storage",
        "Microsoft.ContainerRegistry",
        "Microsoft.Sql",
        "Microsoft.EventHub",
        "Microsoft.ServiceBus",
    ]
}

resource "azurerm_subnet" "controller" {
    name = "controller"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [
        cidrsubnet(var.vnet_cidr, 8, 64)
    ]
    service_endpoints = []
}

resource "azurerm_network_security_group" "worker_nsg" {
    name = "worker_nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "worker_nsg_eventhub" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.worker_nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    log {
        category = "NetworkSecurityGroupEvent"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "NetworkSecurityGroupRuleCounter"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
}

resource "azurerm_network_security_group" "controller_nsg" {
    name = "controller_nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "controller_nsg_eventhub" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.controller_nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    log {
        category = "NetworkSecurityGroupEvent"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "NetworkSecurityGroupRuleCounter"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
}

resource "azurerm_subnet_network_security_group_association" "worker_nsg_assoc" {
    subnet_id = azurerm_subnet.worker.id
    network_security_group_id = azurerm_network_security_group.worker_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "controller_nsg_assoc" {
    subnet_id = azurerm_subnet.controller.id
    network_security_group_id = azurerm_network_security_group.controller_nsg.id
}

resource "azurerm_route_table" "rt" {
    name = "routes"
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

resource "azurerm_subnet_route_table_association" "worker_rt_assoc" {
    subnet_id = azurerm_subnet.worker.id
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_subnet_route_table_association" "controller_rt_assoc" {
    subnet_id = azurerm_subnet.controller.id
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_lb" "lb" {
    name = "lb"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"

    frontend_ip_configuration {
        name = "workers"
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(azurerm_subnet.worker.address_prefixes[0], 4)
        subnet_id = azurerm_subnet.worker.id
    }

    tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "worker_pool" {
    name = "worker_pool"
    loadbalancer_id = azurerm_lb.lb.id
    resource_group_name = azurerm_resource_group.rg.name
}






