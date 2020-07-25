resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["192.168.6.0/24"]

    tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "host" {
    name = "${azurerm_virtual_network.vnet.name}-uksouth-host"
    resource_group_name = var.private_dns_link_bink_host[0]
    private_dns_zone_name = var.private_dns_link_bink_host[1]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "sh" {
    name = "${azurerm_virtual_network.vnet.name}-uksouth-sh"
    resource_group_name = var.private_dns_link_bink_sh[0]
    private_dns_zone_name = var.private_dns_link_bink_sh[1]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = false
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

resource "azurerm_subnet" "subnet" {
    count = length(var.subnet_address_prefixes)
    name = format("subnet-%02d", count.index + 1)
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [element(var.subnet_address_prefixes, count.index)]
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    count = length(var.subnet_address_prefixes)
    name = "binkuksouthlogs"
    target_resource_id = element(azurerm_network_security_group.nsg.*.id, count.index)
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

resource "azurerm_virtual_network_peering" "bastion" {
    name = "local-to-bastion"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-bastion/providers/Microsoft.Network/virtualNetworks/bastion-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = false
}

resource "azurerm_virtual_network_peering" "tools" {
    name = "local-to-tools"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-tools/providers/Microsoft.Network/virtualNetworks/tools-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = false
}

resource "azurerm_virtual_network_peering" "sandbox" {
    name = "local-to-sandbox"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-sandbox/providers/Microsoft.Network/virtualNetworks/sandbox-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = false
}

resource "azurerm_virtual_network_peering" "dev" {
    name = "local-to-dev"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-dev/providers/Microsoft.Network/virtualNetworks/dev-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = false
}

resource "azurerm_virtual_network_peering" "staging" {
    name = "local-to-staging"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-staging/providers/Microsoft.Network/virtualNetworks/staging-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = false
}

resource "azurerm_virtual_network_peering" "prod" {
    name = "local-to-prod"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-prod/providers/Microsoft.Network/virtualNetworks/prod-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = false
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

    tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "pools" {
    count = length(var.subnet_address_prefixes)
    name = format("subnet-%02d", count.index + 1)
    loadbalancer_id = azurerm_lb.lb.id
    resource_group_name = azurerm_resource_group.rg.name
}