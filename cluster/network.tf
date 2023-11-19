resource "azurerm_virtual_network" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    address_space = [var.common.cidr]
}

resource "azurerm_monitor_diagnostic_setting" "vnet" {
    count = var.loganalytics.enabled ? 1 : 0

    name = "loganalytics"
    target_resource_id = azurerm_virtual_network.i.id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

    enabled_log { category = "VMProtectionAlerts" }
    metric {
        category = "AllMetrics"
        enabled = false
    }
}

resource "azurerm_virtual_network_peering" "local" {
    name = "${azurerm_resource_group.i.name}-to-${var.firewall.resource_group_name}"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.firewall.vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "remote" {
    provider = azurerm.core

    name = "${var.firewall.resource_group_name}-to-${azurerm_resource_group.i.name}"
    resource_group_name = var.firewall.resource_group_name
    virtual_network_name = var.firewall.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_subnet" "kube_nodes" {
    name = "AzureKubernetesService"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = [cidrsubnet(var.common.cidr, 1, 0)] # 10.0.0.0/17
    service_endpoints = [
        "Microsoft.AzureActiveDirectory",
        "Microsoft.ContainerRegistry",
        "Microsoft.KeyVault",
        "Microsoft.Storage",
    ]
    lifecycle {
        ignore_changes = [ delegation ]
    }
}

resource "azurerm_subnet" "kube_controller" {
    name = "AzureKubernetesServiceController"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = [cidrsubnet(var.common.cidr, 8, 128)] #10.0.128.0/24

    lifecycle {
        ignore_changes = [ delegation ]
    }
}

resource "azurerm_subnet" "postgres" {
    name = "AzurePostgres"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = [cidrsubnet(var.common.cidr, 8, 129)] #10.0.129.0/24
    service_endpoints = [ "Microsoft.Storage" ]
    delegation {
        name = "flexible_server"
        service_delegation {
            name = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions = [
                "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
        }
    }
}

resource "azurerm_subnet" "redis" {
    name = "AzureRedis"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = [cidrsubnet(var.common.cidr, 8, 130)] #10.0.130.0/24
}

resource "azurerm_subnet" "tableau" {
    name = "Tableau"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = [cidrsubnet(var.common.cidr, 8, 131)] #10.0.131.0/24
}

resource "azurerm_subnet" "cloudamqp" {
    name = "CloudAMQP"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = [cidrsubnet(var.common.cidr, 8, 132)] #10.0.132.0/24
}

resource "azurerm_route_table" "i" {
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    disable_bgp_route_propagation = true

    route {
        name = "default"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.firewall.ip
    }
}

resource "azurerm_subnet_route_table_association" "kube_nodes" {
    subnet_id = azurerm_subnet.kube_nodes.id
    route_table_id = azurerm_route_table.i.id
}

resource "azurerm_subnet_route_table_association" "tableau" {
    subnet_id = azurerm_subnet.tableau.id
    route_table_id = azurerm_route_table.i.id
}
