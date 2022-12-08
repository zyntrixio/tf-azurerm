terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
    }
}

variable "peers" { type = map(object({
    vnet_id = string
    vnet_name = string
    resource_group_name = string
})) }

variable "private_dns" {
    type = object({
        resource_group = string
        primary_zone = string
        secondary_zones = list(string)
    })
}

variable "ip_range" { type = string }

resource "azurerm_resource_group" "i" {
    name = "uksouth-opensearch"
    location = "uksouth"
}

resource "azurerm_network_security_group" "i" {
    name = "opensearch"
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
            "Allow_TCP_9200" = {"priority": "200", "port": "9200", "source": "10.0.0.0/8"},
            "Allow_TCP_80" = {"priority": "210", "port": "80", "source": "192.168.0.0/24"},
            "Allow_TCP_443" = {"priority": "220", "port": "443", "source": "192.168.0.0/24"},
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
            destination_address_prefix = var.ip_range
        }
    }
}

resource "azurerm_virtual_network" "i" {
    name = "opensearch"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    address_space = [ var.ip_range ]
    subnet {
        address_prefix = var.ip_range
        name = "subnet"
        security_group = azurerm_network_security_group.i.id
    }
}

resource "azurerm_virtual_network_peering" "local" {
    for_each = var.peers
    name = "local-to-${each.key}"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = each.value["vnet_id"]
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "remote" {
    for_each = var.peers
    name = "local-to-${azurerm_resource_group.i.name}"
    resource_group_name = each.value["resource_group_name"]
    virtual_network_name = each.value["vnet_name"]
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
    name = azurerm_virtual_network.i.name
    resource_group_name = var.private_dns.resource_group
    private_dns_zone_name = var.private_dns.primary_zone
    virtual_network_id = azurerm_virtual_network.i.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
    for_each = toset(var.private_dns.secondary_zones)
    name = azurerm_virtual_network.i.name
    resource_group_name = var.private_dns.resource_group
    private_dns_zone_name = each.key
    virtual_network_id = azurerm_virtual_network.i.id
}

resource "azurerm_route_table" "i" {
    name = "opensearch"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    disable_bgp_route_propagation = false

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = "192.168.0.4"
    }
}

resource "azurerm_subnet_route_table_association" "i" {
    subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
    route_table_id = azurerm_route_table.i.id
}

resource "azurerm_managed_disk" "i" {
    name = "opensearch"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    storage_account_type = "Premium_LRS"
    create_option = "Empty"
    disk_size_gb = "1000"
}

resource "azurerm_network_interface" "i" {
    name = "opensearch"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    enable_accelerated_networking = true

    ip_configuration {
        name = "internal"
        subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "i" {
    name = "opensearch"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    size = "Standard_E2ads_v5"
    admin_username      = "terraform"
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
        offer = "0001-com-ubuntu-server-focal"
        sku = "20_04-lts"
        version = "latest"
    }

    lifecycle {
        ignore_changes = [custom_data]
    }
}

resource "azurerm_virtual_machine_data_disk_attachment" "i" {
    managed_disk_id = azurerm_managed_disk.i.id
    virtual_machine_id = azurerm_linux_virtual_machine.i.id
    lun = "0"
    caching = "ReadOnly"
}
