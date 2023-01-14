terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
    }
    required_version = ">= 1.3.2"
}

variable "common" {
    type = object({
        firewall = object({
            name = string
            resource_group = string
            ip_address = string
            public_ip = string
            vnet_name = string
            vnet_id = string
        })
        private_dns = object({
            resource_group = string
            primary_zone = string
            secondary_zones = list(string)
        })
        cidr = string
        loganalytics_id = string
        vm_size = optional(string, "Standard_B2s")
        tags = optional(map(string), {
            Environment = "Core"
            Role = "Bastion"
        })
        location = optional(string, "uksouth")
    })
}

resource "azurerm_resource_group" "i" {
    name = "${var.common.location}-bastion"
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
    name = azurerm_resource_group.i.name
    resource_group_name = var.common.private_dns.resource_group
    private_dns_zone_name = var.common.private_dns.primary_zone
    virtual_network_id = azurerm_virtual_network.i.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
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

    dynamic security_rule {
        for_each = {
            "Allow_TCP_22" = {"priority": "100", "port": "22", "source": "192.168.0.0/24"},
            "Allow_TCP_9100" = {"priority": "110", "port": "9100", "source": "10.50.0.0/16"},
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

resource "azurerm_route_table" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    disable_bgp_route_propagation = true

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.common.firewall.ip_address
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

resource "azurerm_virtual_network_peering" "firewall_to_local" {
    name = "local-to-${azurerm_resource_group.i.name}"
    resource_group_name = var.common.firewall.resource_group
    virtual_network_name = var.common.firewall.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "local_to_firewall" {
    name = "${var.common.firewall.resource_group}-to-local"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.common.firewall.vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_network_interface" "i" {
    name = "bastion"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name

    ip_configuration {
        name = "ipconfig"
        subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_firewall_nat_rule_collection" "i" {
    name = azurerm_resource_group.i.name
    azure_firewall_name = var.common.firewall.name
    resource_group_name = var.common.firewall.resource_group
    priority = 100
    action = "Dnat"

    rule {
        name = "ssh"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = [var.common.firewall.public_ip]
        translated_address = azurerm_network_interface.i.private_ip_address
        translated_port = "22"
        protocols = ["TCP"]
    }
}

resource "azurerm_linux_virtual_machine" "i" {
    name = "bastion"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    size = var.common.vm_size
    admin_username = "terraform"
    tags = var.common.tags
    network_interface_ids = [
        azurerm_network_interface.i.id,
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
