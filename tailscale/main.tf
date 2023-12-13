terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
    }
}

variable common {
    type = object({
        location = optional(string, "uksouth")
        secure_origins_v4 = list(string)
        secure_origins_v6 = list(string)
    })
}

variable "dns" {
    type = object({
        record = string
        resource_group_name = string
        zone_name = string
    })
}

locals {
    storage_allowed_ips = [for ip in var.common.secure_origins_v4: replace(ip, "/32", "")]
}

output "ip_addresses" {
    value = {
        ipv4 = azurerm_public_ip.v4.ip_address
        ipv6 = azurerm_public_ip.v6.ip_address
    }
}

resource "azurerm_resource_group" "i" {
    name = "${var.common.location}-tailscale"
    location = var.common.location
}

resource "azurerm_public_ip" "v4" {
    name = "${azurerm_resource_group.i.name}_v4"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    ip_version = "IPv4"
    allocation_method = "Static"
    sku = "Standard"
    zones = [ "1", "2", "3" ]
}

resource "azurerm_public_ip" "v6" {
    name = "${azurerm_resource_group.i.name}_v6"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    ip_version = "IPv6"
    allocation_method = "Static"
    sku = "Standard"
    zones = [ "1", "2", "3" ]
}

resource "azurerm_dns_a_record" "i" {
    name = var.dns.record
    zone_name = var.dns.zone_name
    resource_group_name = var.dns.resource_group_name
    ttl = 3600
    records = [azurerm_public_ip.v4.ip_address]
}

resource "azurerm_dns_aaaa_record" "i" {
    name = var.dns.record
    zone_name = var.dns.zone_name
    resource_group_name = var.dns.resource_group_name
    ttl = 3600
    records = [azurerm_public_ip.v6.ip_address]
}

resource "azurerm_virtual_network" "i" {
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    address_space = ["192.168.1.0/24", "ace:cab:deca:deed::/64"]
}

resource "azurerm_subnet" "i" {
    name = "subnet"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = ["192.168.1.0/24", "ace:cab:deca:deed::/64"]
}

resource "azurerm_network_security_group" "i" {
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location

    security_rule {
        name = "BlockEverything"
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
        name = "Wireguard"
        access = "Allow"
        priority = 200
        direction = "Inbound"
        protocol = "Udp"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "51820"
    }

    dynamic security_rule {
        for_each = { for id, cidr in concat(var.common.secure_origins_v4, var.common.secure_origins_v6): cidr => id}
        content {
            name = "SSH_Rule_${security_rule.value}"
            access = "Allow"
            priority = security_rule.value + 500
            direction = "Inbound"
            protocol = "Tcp"
            source_address_prefix = security_rule.key
            source_port_range = "*"
            destination_address_prefix = "*"
            destination_port_range = "22"
        }
    }
}

resource "azurerm_subnet_network_security_group_association" "i" {
    subnet_id = azurerm_subnet.i.id
    network_security_group_id = azurerm_network_security_group.i.id
}

resource "azurerm_network_interface" "i" {
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    enable_accelerated_networking = true

    ip_configuration {
        name = "IPv4"
        primary = true
        subnet_id = azurerm_subnet.i.id
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost("192.168.1.0/24", 4)
        private_ip_address_version = "IPv4"
        public_ip_address_id = azurerm_public_ip.v4.id
    }

    ip_configuration {
        name = "IPv6"
        subnet_id = azurerm_subnet.i.id
        private_ip_address_allocation = "Static"
        private_ip_address = "ace:cab:deca:deed::4"
        private_ip_address_version = "IPv6"
        public_ip_address_id = azurerm_public_ip.v6.id
    }
}

resource "azurerm_linux_virtual_machine" "i" {
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    size = "Standard_D2ads_v5"
    admin_username = "terraform"
    network_interface_ids = [ azurerm_network_interface.i.id ]

    admin_ssh_key {
        username   = "terraform"
        public_key = file("ssh.pub")
    }

    os_disk {
        disk_size_gb = 32
        caching = "ReadOnly"
        storage_account_type = "Premium_ZRS"
    }

    source_image_reference {
        publisher = "Debian"
        offer = "debian-12"
        sku = "12-gen2"
        version = "latest"
    }
}
