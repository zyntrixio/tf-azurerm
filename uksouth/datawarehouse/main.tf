terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">= 3.26.0"
            configuration_aliases = [ azurerm.core ]
        }
    }
}

variable "common" {
    type = object({
        location = optional(string, "uksouth")
        environment = string
        cidr = string
        firewall_ip = string
        loganalytics_id = string
        private_dns = object({
            resource_group = string
            primary_zone = string
            secondary_zones = list(string)
        })
        postgres_dns = object({
            name = string
            resource_group_name = string
        })
        peering = object({
            firewall = object({
                vnet_id = string
                vnet_name = string
                resource_group = string
            })
            environment = object({
                vnet_id = string
                vnet_name = string
                resource_group = string
            })
        })
        vms = map(object({
            size = string
        }))
    })
}

resource "azurerm_resource_group" "i" {
    name = "${var.common.location}-${var.common.environment}-datawarehouse"
    location = var.common.location
}

resource "azurerm_virtual_network" "i" {
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    address_space = [ var.common.cidr ]

    subnet {
        name = "subnet"
        address_prefix = var.common.cidr
    }

    lifecycle {ignore_changes = [subnet]}
}

resource "azurerm_network_security_group" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name

    security_rule {
        name = "BlockEverything"
        priority = "4096"
        access = "Deny"
        protocol = "*"
        direction = "Inbound"
        source_port_range = "*"
        source_address_prefix = "*"
        destination_port_range = "*"
        destination_address_prefix = "*"
    }

    dynamic security_rule {
        for_each = {
            "Allow_TCP_22" = {"priority": "100", "port": "22", "source": "192.168.4.0/24"},
            "Allow_TCP_9100" = {"priority": "110", "port": "9100", "source": "10.50.0.0/16"},
            "Allow_TCP_4200" = {"priority": "200", "port": "4200", "source": "*"},
            "Allow_TCP_8000" = {"priority": "210", "port": "8000", "source": "*"},
            "Allow_TCP_8080" = {"priority": "220", "port": "8080", "source": "*"},
        }
        content {
            name = security_rule.key
            priority = security_rule.value.priority
            access = "Allow"
            protocol = "Tcp"
            direction = "Inbound"
            source_port_range = "*"
            source_address_prefix = security_rule.value.source
            destination_port_range = security_rule.value.port
            destination_address_prefix = var.common.cidr
        }
    }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.i.id
    log_analytics_workspace_id = var.common.loganalytics_id

    enabled_log { category = "NetworkSecurityGroupEvent" }
    enabled_log { category = "NetworkSecurityGroupRuleCounter" }
}

resource "azurerm_subnet_network_security_group_association" "i" {
    subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
    network_security_group_id = azurerm_network_security_group.i.id
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
        next_hop_in_ip_address = var.common.firewall_ip
    }
}

resource "azurerm_subnet_route_table_association" "i" {
    subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
    route_table_id = azurerm_route_table.i.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
    provider = azurerm.core
    name = azurerm_virtual_network.i.name
    resource_group_name = var.common.private_dns.resource_group
    private_dns_zone_name = var.common.private_dns.primary_zone
    virtual_network_id = azurerm_virtual_network.i.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
    provider = azurerm.core
    for_each = toset(var.common.private_dns.secondary_zones)
    name = azurerm_virtual_network.i.name
    resource_group_name = var.common.private_dns.resource_group
    private_dns_zone_name = each.key
    virtual_network_id = azurerm_virtual_network.i.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "pg" {
    name = "private.postgres.database.azure.com-to-${azurerm_resource_group.i.name}"
    private_dns_zone_name = var.common.postgres_dns.name
    virtual_network_id = azurerm_virtual_network.i.id
    resource_group_name = var.common.postgres_dns.resource_group_name
}

resource "azurerm_virtual_network_peering" "firewall_to_local" {
    provider = azurerm.core
    name = "local-to-${azurerm_resource_group.i.name}"
    resource_group_name = var.common.peering.firewall.resource_group
    virtual_network_name = var.common.peering.firewall.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "local_to_firewall" {
    name = "${var.common.peering.firewall.resource_group}-to-local"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.common.peering.firewall.vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "environment_to_local" {
    name = "local-to-${azurerm_resource_group.i.name}"
    resource_group_name = var.common.peering.environment.resource_group
    virtual_network_name = var.common.peering.environment.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "local_to_environment" {
    name = "${var.common.peering.environment.resource_group}-to-local"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.common.peering.environment.vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_network_interface" "i" {
    for_each = var.common.vms
    name = each.key
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location

    ip_configuration {
        name = "ipconfig"
        subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "i" {
    for_each = var.common.vms
    name = each.key
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    size = each.value.size
    admin_username = "terraform"
    network_interface_ids = [
        azurerm_network_interface.i[each.key].id,
    ]

    admin_ssh_key {
        username   = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        disk_size_gb = 128
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
