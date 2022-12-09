terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">= 3.34.0"
            configuration_aliases = [ azurerm.core ]
        }
    }
    required_version = ">= 1.3.2"
}

variable "common" {
    type = object({
        firewall = object({
            vnet_id = string
            vnet_name = string
            rg_name = string
            firewall_name = string
            firewall_ip = string
            rule_priority = number
        })
        private_dns = object({
            resource_group = string
            primary_zone = string
            secondary_zones = list(string)
        })
        client_cidrs = list(string)
        environment = string
        cidr = string
        loganalytics_id = string
        vm_size = optional(string, "Standard_D4as_v5")
        tags = map(string)
        location = optional(string, "uksouth")
        node_count = optional(number, 3)
    })
}

resource "azurerm_resource_group" "i" {
    name = "${var.common.location}-${var.common.environment}-amqp"
    location = var.common.location

    tags = var.common.tags
}

resource "azurerm_virtual_network" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    address_space = [var.common.cidr]
    tags = var.common.tags

    subnet {
        name = "subnet"
        address_prefix = var.common.cidr
    }

    lifecycle {ignore_changes = [subnet]}
}

resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
    provider = azurerm.core

    name = azurerm_resource_group.i.name
    resource_group_name = var.common.private_dns.resource_group
    private_dns_zone_name = var.common.private_dns.primary_zone
    virtual_network_id = azurerm_virtual_network.i.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
    provider = azurerm.core

    for_each = toset(var.common.private_dns.secondary_zones)
    name = azurerm_resource_group.i.name
    resource_group_name = var.common.private_dns.resource_group
    private_dns_zone_name = each.key
    virtual_network_id = azurerm_virtual_network.i.id
}

resource "azurerm_network_security_group" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name

    tags = var.common.tags

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

    security_rule {
        name = "Allow_LB"
        description = "Allow Healthchecks from Load Balancer"
        access = "Allow"
        priority = 100
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefix = "AzureLoadBalancer"
        source_port_range = "*"
        destination_address_prefix = var.common.cidr
        destination_port_ranges = [5671, 15671]
    }

    security_rule {
        name = "Allow_Clustering"
        description = "Allow RabbitMQ nodes to talk to each other"
        access = "Allow"
        priority = 110
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefix = var.common.cidr
        source_port_range = "*"
        destination_address_prefix = var.common.cidr
        destination_port_ranges = [4369, 5671, 15671, 25672, "35672-35682"]
    }

    security_rule {
        name = "Allow_Clients"
        description = "Allow RabbitMQ Clients to connect to RabbitMQ Server"
        access = "Allow"
        priority = 120
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefixes = var.common.client_cidrs
        source_port_range = "*"
        destination_address_prefix = var.common.cidr
        destination_port_ranges = [5671, 15671]
    }

    security_rule {
        name = "Allow_SSH"
        description = "Allow SSH Connections from Bastion Hosts"
        access = "Allow"
        priority = 130
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefix = "192.168.4.0/24"
        source_port_range = "*"
        destination_address_prefix = var.common.cidr
        destination_port_range = 22
    }

    security_rule {
        name = "AllowNodeExporterAccess"
        description = "Tools Prometheus -> Node Exporter"
        access = "Allow"
        priority = 140
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefix = "10.33.0.0/18"
        source_port_range = "*"
        destination_address_prefix = var.common.cidr
        destination_port_range = 9100
    }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.i.id
    log_analytics_workspace_id = var.common.loganalytics_id

    log {
        category = "NetworkSecurityGroupEvent"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "NetworkSecurityGroupRuleCounter"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
}

resource "azurerm_virtual_network_peering" "firewall_to_local" {
    provider = azurerm.core

    name = "local-to-${azurerm_resource_group.i.name}"
    resource_group_name = var.common.firewall.rg_name
    virtual_network_name = var.common.firewall.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "local_to_firewall" {
    name = "${var.common.firewall.rg_name}-to-local"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.common.firewall.vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_firewall_network_rule_collection" "i" {
    provider = azurerm.core

    name = azurerm_resource_group.i.name
    azure_firewall_name = var.common.firewall.firewall_name
    resource_group_name = var.common.firewall.rg_name
    priority = var.common.firewall.rule_priority
    action = "Allow"

    rule {
        name = "amqp"
        source_addresses = var.common.client_cidrs
        destination_ports = ["5671", "15671"]
        destination_addresses = [var.common.cidr]
        protocols = ["TCP"]
    }
}

resource "azurerm_route_table" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    disable_bgp_route_propagation = true

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.common.firewall.firewall_ip
    }

    tags = var.common.tags
}

resource "azurerm_subnet_network_security_group_association" "i" {
    subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
    network_security_group_id = azurerm_network_security_group.i.id
}

resource "azurerm_subnet_route_table_association" "i" {
    subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
    route_table_id = azurerm_route_table.i.id
}

resource "azurerm_lb" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    sku = "Standard"

    frontend_ip_configuration {
        name = "frontend"
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.common.cidr, 4)
        subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
        zones = [ "1", "2", "3" ]
    }

    tags = var.common.tags
}

resource "azurerm_private_dns_a_record" "i" {
    provider = azurerm.core

    name = "amqp"
    zone_name = var.common.private_dns.primary_zone
    resource_group_name = var.common.private_dns.resource_group
    ttl = 3600
    records = azurerm_lb.i.private_ip_addresses
}


resource "azurerm_lb_backend_address_pool" "i" {
    name = "rabbits"
    loadbalancer_id = azurerm_lb.i.id
}

resource "azurerm_lb_probe" "amqp" {
    loadbalancer_id = azurerm_lb.i.id
    name = "amqp"
    port = 5671
}

resource "azurerm_lb_rule" "amqp" {
    loadbalancer_id = azurerm_lb.i.id
    name = "amqp"
    protocol = "Tcp"
    frontend_port = 5671
    backend_port = 5671
    frontend_ip_configuration_name = "frontend"
    backend_address_pool_ids = [ azurerm_lb_backend_address_pool.i.id ]
    probe_id = azurerm_lb_probe.amqp.id
}

resource "azurerm_lb_probe" "webui" {
    loadbalancer_id = azurerm_lb.i.id
    name = "webui"
    port = 15671
}

resource "azurerm_lb_rule" "webui" {
    loadbalancer_id = azurerm_lb.i.id
    name = "webui"
    protocol = "Tcp"
    frontend_port = 15671
    backend_port = 15671
    frontend_ip_configuration_name = "frontend"
    backend_address_pool_ids = [ azurerm_lb_backend_address_pool.i.id ]
    probe_id = azurerm_lb_probe.amqp.id
}

resource "azurerm_network_interface" "i" {
    count = var.common.node_count
    name = "amqp${count.index}"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    enable_accelerated_networking = true

    ip_configuration {
        name = "ipconfig"
        subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "i" {
    count = var.common.node_count
    network_interface_id = azurerm_network_interface.i[count.index].id
    ip_configuration_name = "ipconfig"
    backend_address_pool_id = azurerm_lb_backend_address_pool.i.id
}

resource "azurerm_linux_virtual_machine" "i" {
    count = var.common.node_count
    name = azurerm_network_interface.i[count.index].name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    size = var.common.vm_size
    admin_username = "terraform"
    tags = var.common.tags
    zone = count.index + 1
    network_interface_ids = [
        azurerm_network_interface.i[count.index].id,
    ]

    admin_ssh_key {
        username   = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        disk_size_gb = 32
        caching = "ReadOnly"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts-gen2"
        version = "latest"
    }
}
