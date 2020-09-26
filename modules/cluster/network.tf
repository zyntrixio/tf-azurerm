resource "azurerm_virtual_network" "vnet" {
    name = "${var.cluster_name}-vnet"
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
    name = "${var.cluster_name}-worker-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name = "BlockEverything"
        priority = 4096
        protocol = "*"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_port_range = "*"
        destination_address_prefix = "*"
        access = "Deny"
        direction = "Inbound"
    }
    security_rule {
        name = "AllowLoadBalancer"
        protocol = "*"
        source_address_prefix = "AzureLoadBalancer"
        source_port_range = "*"
        destination_port_range = "*"
        destination_address_prefix = "*"
        priority = 4095
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowSSH"
        priority = 500
        protocol = "TCP"
        destination_port_range = 22
        source_port_range = "*"
        destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        source_address_prefix = "192.168.4.0/24"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowAllSubnetTraffic"
        priority = 100
        protocol = "*"
        source_port_range = "*"
        destination_port_range = "*"
        destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        source_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {  # This allows apiserver to get logs etc...
        name = "AllowAllControllerSubnetTraffic"
        priority = 110
        protocol = "*"
        source_port_range = "*"
        destination_port_range = "*"
        destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        source_address_prefix = azurerm_subnet.controller.address_prefixes[0]
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowHttpTrafficFromLoadbalancer"
        priority = 120
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = 30000
        destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        source_address_prefix = "AzureLoadBalancer"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowHttpsTrafficFromLoadbalancer"
        priority = 130
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = 30001
        destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        source_address_prefix = "AzureLoadBalancer"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowHttpTrafficFromFirewall"
        priority = 140
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = 30000
        destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        source_address_prefix = "192.168.0.0/24"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowHttpsTrafficFromFirewall"
        priority = 150
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = 30001
        destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        source_address_prefix = "192.168.0.0/24"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowPrometheusNodeExporter"
        priority = 160
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = 9100
        destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        source_address_prefix = "10.4.0.0/18"
        direction = "Inbound"
        access = "Allow"
    }

    dynamic "security_rule" {
        for_each = var.tcp_endpoint ? ["1"] : []
        content {
            name = "AllowTCPTrafficFromFirewall"
            priority = 170
            protocol = "TCP"
            source_port_range = "*"
            destination_port_range = 30002
            destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
            source_address_prefix = "10.0.0.0/8"  # Replace with variable passed in ideally
            direction = "Inbound"
            access = "Allow"
        }
    }

    dynamic "security_rule" {
        for_each = var.tcp_endpoint ? ["1"] : []
        content {
            name = "AllowTCPTrafficFromLoadbalancer"
            priority = 171
            protocol = "TCP"
            source_port_range = "*"
            destination_port_range = 30002
            destination_address_prefix = azurerm_subnet.worker.address_prefixes[0]
            source_address_prefix = "AzureLoadBalancer"
            direction = "Inbound"
            access = "Allow"
        }
    }

    tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "worker_nsg_eventhub" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.worker_nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = var.eventhub_authid

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
    name = "${var.cluster_name}-controller-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name = "BlockEverything"
        priority = 4096
        protocol = "*"
        access = "Deny"
        source_port_range = "*"
        destination_port_range = "*"
        destination_address_prefix = "*"
        source_address_prefix = "*"
        direction = "Inbound"
    }
    security_rule {
        name = "AllowSSH"
        priority = 500
        protocol = "TCP"
        destination_port_range = 22
        source_port_range = "*"
        destination_address_prefix = azurerm_subnet.controller.address_prefixes[0]
        source_address_prefix = "192.168.4.0/24"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowKubeAPIAccessWorkers"
        priority = 100
        protocol = "TCP"
        destination_port_range = 6443
        source_port_range = "*"
        destination_address_prefix = azurerm_subnet.controller.address_prefixes[0]
        source_address_prefix = azurerm_subnet.worker.address_prefixes[0]
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowKubeAPIAccessExternal"
        priority = 110
        protocol = "TCP"
        destination_port_range = 6443
        source_port_range = "*"
        destination_address_prefix = azurerm_subnet.controller.address_prefixes[0]
        source_address_prefix = "192.168.0.0/24"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowPrometheusNodeExporter"
        priority = 120
        protocol = "TCP"
        source_port_range = "*"
        destination_port_range = 9100
        destination_address_prefix = azurerm_subnet.controller.address_prefixes[0]
        source_address_prefix = "10.4.0.0/18"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowPrometheusToKubeAPI"
        priority = 130
        protocol = "TCP"
        destination_port_range = 6443
        source_port_range = "*"
        destination_address_prefix = azurerm_subnet.controller.address_prefixes[0]
        source_address_prefix = "10.4.0.0/18"
        direction = "Inbound"
        access = "Allow"
    }

    tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "controller_nsg_eventhub" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.controller_nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = var.eventhub_authid

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
    name = "${var.cluster_name}-routes"
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

resource "azurerm_postgresql_virtual_network_rule" "workers" {
    for_each = var.postgres_servers

    name = "${var.cluster_name}-workers"
    resource_group_name = each.value
    server_name = each.key
    subnet_id = azurerm_subnet.worker.id
}

resource "azurerm_lb" "lb" {
    name = "${var.cluster_name}-lb"
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
    name = "workers"
    loadbalancer_id = azurerm_lb.lb.id
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_lb_rule" "https" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "HTTPS"
    protocol = "Tcp"
    frontend_port = 30001
    backend_port = 30001
    frontend_ip_configuration_name = "workers"
    backend_address_pool_id = azurerm_lb_backend_address_pool.worker_pool.id
    probe_id = azurerm_lb_probe.https.id
}

resource "azurerm_lb_probe" "https" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "https-probe"
    port = 30001
}

resource "azurerm_lb_rule" "http" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "HTTP"
    protocol = "Tcp"
    frontend_port = 30000
    backend_port = 30000
    frontend_ip_configuration_name = "workers"
    backend_address_pool_id = azurerm_lb_backend_address_pool.worker_pool.id
    probe_id = azurerm_lb_probe.http.id
}

resource "azurerm_lb_probe" "http" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "http-probe"
    port = 30000
}

resource "azurerm_lb_rule" "tcp" {
    count = var.tcp_endpoint ? 1 : 0
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "TCP"
    protocol = "Tcp"
    frontend_port = 30002
    backend_port = 30002
    frontend_ip_configuration_name = "workers"
    backend_address_pool_id = azurerm_lb_backend_address_pool.worker_pool.id
    probe_id = azurerm_lb_probe.tcp[0].id
}

resource "azurerm_lb_probe" "tcp" {
    count = var.tcp_endpoint ? 1 : 0
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "tcp-probe"
    port = 30002
}
