terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.95.0"
      configuration_aliases = [ azurerm.core ]
    }
    chef = {
      source = "terrycain/chef"
    }
  }
  required_version = ">= 0.13"
}

resource "chef_environment" "i" {
    name = var.resource_group_name
}

resource "azurerm_resource_group" "i" {
    name = var.resource_group_name
    location = var.location
    tags = var.tags
}

resource "azurerm_virtual_network" "i" {
    name = "${var.resource_group_name}-vnet"
    location = var.location
    resource_group_name = azurerm_resource_group.i.name
    address_space = [var.vnet_cidr]
    tags = var.tags
}

resource "azurerm_subnet" "i" {
    name = "subnet"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = [var.vnet_cidr]
}

resource "azurerm_network_security_group" "i" {
    name = "${var.resource_group_name}-nsg"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name

    tags = var.tags

    security_rule {
        name = "Allow_Clients"
        description = "Allow ClickHouse Clients"
        access = "Allow"
        priority = 100
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefixes = var.cluster_cidrs
        source_port_range = "*"
        destination_address_prefix = var.vnet_cidr
        destination_port_range = 8443
    }
    security_rule {
        name = "Allow_Aiden"
        description = "Allow Aiden to connect to airbyte"
        access = "Allow"
        priority = 101
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = var.vnet_cidr
        destination_port_range = 8000
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
        destination_address_prefix = var.vnet_cidr
        destination_port_range = 22
    }

    security_rule {
        name = "AllowPrometheus"
        description = "Allow Prometheus from Tools Cluster"
        access = "Allow"
        priority = 140
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefix = "10.33.0.0/18"
        source_port_range = "*"
        destination_address_prefix = var.vnet_cidr
        destination_port_ranges = [9100, 9101]
    }

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
}


resource "azurerm_subnet_network_security_group_association" "i" {
    subnet_id = azurerm_subnet.i.id
    network_security_group_id = azurerm_network_security_group.i.id
}

resource "azurerm_route_table" "i" {
    name = "${azurerm_resource_group.i.name}-routes"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    disable_bgp_route_propagation = true

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = "192.168.0.4"
    }

    tags = var.tags
}

resource "azurerm_subnet_route_table_association" "i" {
    subnet_id = azurerm_subnet.i.id
    route_table_id = azurerm_route_table.i.id
}

resource "azurerm_virtual_network_peering" "source" {
    name = "local-to-firewall"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.peering_remote_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "remote" {
    provider = azurerm.core

    name = "local-to-${azurerm_resource_group.i.name}"
    resource_group_name = var.peering_remote_rg
    virtual_network_name = var.peering_remote_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "i" {
    for_each = var.dns

    provider = azurerm.core

    name = "${azurerm_virtual_network.i.name}-${each.key}"
    resource_group_name = each.value["resource_group_name"]
    private_dns_zone_name = each.value["private_dns_zone_name"]
    virtual_network_id = azurerm_virtual_network.i.id
    registration_enabled = each.value["should_register"]
}

resource "azurerm_network_interface" "i" {
    name = "prod-clickhouse"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    enable_accelerated_networking = true

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.i.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }
}

resource "azurerm_linux_virtual_machine" "i" {
    name = "prod-clickhouse"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    size = "Standard_D2as_v4"
    admin_username = "terraform"
    network_interface_ids = [
        azurerm_network_interface.i.id
    ]

    admin_ssh_key {
        username = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadOnly"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 128
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-focal"
        sku = "20_04-lts"
        version = "latest"
    }

    custom_data = base64gzip(
        templatefile(
            "${path.root}/init.tmpl",
            {
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[clickhouse]"] })),
                cinc_environment = chef_environment.i.name,
                cinc_data_secret = ""
            }
        )
    )

    lifecycle { ignore_changes = [custom_data] }
}
