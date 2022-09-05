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

variable "firewall" { type = map }
variable "environment" { type = map }
variable "private_dns_link_bink_host" { type = list }
variable postgres_flexible_server_dns_link { type = map }

resource "azurerm_resource_group" "i" {
    name = "uksouth-prod-airbyte"
    location = "uksouth"
}

resource "azurerm_network_security_group" "i" {
    name = "airbyte"
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

    security_rule {
        name = "AllowSSH"
        priority = "100"
        access = "Allow"
        protocol = "Tcp"
        direction = "Inbound"
        source_port_range = "*"
        source_address_prefix = "192.168.4.0/24"
        destination_port_range = "22"
        destination_address_prefix = "192.168.23.0/24"
    }

    security_rule {
        name = "AllowHTTP"
        priority = "200"
        access = "Allow"
        protocol = "Tcp"
        direction = "Inbound"
        source_port_range = "*"
        source_address_prefix = "*"
        destination_port_range = "8000"
        destination_address_prefix = "192.168.23.0/24"
    }
}

resource "azurerm_virtual_network" "i" {
    name = "airbyte"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    address_space = [ "192.168.23.0/24" ]
    subnet {
        address_prefix = "192.168.23.0/24"
        name = "subnet"
        security_group = azurerm_network_security_group.i.id
    }
}

resource "chef_environment" "i" {
    name = azurerm_resource_group.i.name
}

resource "chef_role" "i" {
    name = "airbyte"
    run_list = [
        "recipe[fury]",
        "recipe[nebula]"
    ]
}

resource "azurerm_virtual_network_peering" "local-to-fw" {
    name = "local-to-fw"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.firewall.vnet_id
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "fw-to-local" {
    provider = azurerm.core

    name = "local-to-prod-airbyte"
    resource_group_name = var.firewall.resource_group_name
    virtual_network_name = var.firewall.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "local-to-environment" {
    name = "local-to-environment"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.environment.vnet_id
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "environment-to-local" {
    name = "local-to-prod-airbyte"
    resource_group_name = var.environment.resource_group_name
    virtual_network_name = var.environment.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_forwarded_traffic = true
}

resource "azurerm_route_table" "i" {
    name = "airbyte"
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

resource "azurerm_private_dns_zone_virtual_network_link" "i" {
    provider = azurerm.core
    name = "${azurerm_virtual_network.i.name}-uksouth-host"
    resource_group_name = var.private_dns_link_bink_host[0]
    private_dns_zone_name = var.private_dns_link_bink_host[1]
    virtual_network_id = azurerm_virtual_network.i.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "pgfs" {
    name = "private.postgres.database.azure.com-to-${azurerm_resource_group.i.name}"
    private_dns_zone_name = var.postgres_flexible_server_dns_link.name
    virtual_network_id = azurerm_virtual_network.i.id
    resource_group_name = var.postgres_flexible_server_dns_link.resource_group_name
}

resource "azurerm_network_interface" "i" {
    name = "airbyte"
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
    name = "airbyte"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    size = "Standard_D4as_v4"
    admin_username = "terraform"
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

    custom_data = base64gzip(
        templatefile(
            "${path.root}/init.tmpl",
            {
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[airbyte]"] })),
                cinc_environment = chef_environment.i.name
                cinc_data_secret = ""
            }
        )
    )

    lifecycle {
        ignore_changes = [custom_data]
    }
}
