resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.address_space]

    tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "host" {
    name = "${azurerm_virtual_network.vnet.name}-uksouth-host"
    resource_group_name = var.private_dns_link_bink_host[0]
    private_dns_zone_name = var.private_dns_link_bink_host[1]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = true
}

resource "azurerm_network_security_group" "nsg" {
    name = "${var.environment}-subnet-01-nsg"
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
    name = "subnet-01"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.address_space]

    service_endpoints = [
        "Microsoft.EventHub"
    ]
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    log_analytics_workspace_id = var.loganalytics_id

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
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
    subnet_id = azurerm_subnet.subnet.id
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

resource "azurerm_virtual_network_peering" "gitlab" {
    name = "local-to-gitlab"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-gitlab/providers/Microsoft.Network/virtualNetworks/gitlab-vnet"
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

resource "azurerm_virtual_network_peering" "monitoring" {
    name = "local-to-monitoring"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-monitoring/providers/Microsoft.Network/virtualNetworks/monitoring-vnet"
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
        private_ip_address = cidrhost(var.address_space, 4)
        subnet_id = azurerm_subnet.subnet.id
    }

    tags = var.tags
}

resource "azurerm_private_dns_a_record" "lb" {
    name = "elasticsearch"
    zone_name = var.private_dns_link_bink_host[1]
    resource_group_name = var.private_dns_link_bink_host[0]
    ttl = 300
    records = [cidrhost(var.address_space, 4)]
}



resource "azurerm_lb_backend_address_pool" "pool" {
    name = "subnet-01"
    loadbalancer_id = azurerm_lb.lb.id
}
