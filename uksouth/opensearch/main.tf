terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
        chef = {
            source = "terrycain/chef"
        }
    }
}

variable "peers" { type = map(object({
    vnet_id = string
    vnet_name = string
    resource_group_name = string
})) }

variable "private_dns_link_bink_host" { type = list }

resource "azurerm_resource_group" "i" {
    name = "uksouth-opensearch"
    location = "uksouth"
}

resource "chef_environment" "i" {
    name = azurerm_resource_group.i.name
}

resource "chef_role" "i" {
    name = "opensearch"
    run_list = [
        "recipe[fury]",
        "recipe[nebula]"
    ]
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

    security_rule {
        name = "AllowSSH"
        priority = "100"
        access = "Allow"
        protocol = "Tcp"
        direction = "Inbound"
        source_port_range = "*"
        source_address_prefix = "192.168.4.0/24"
        destination_port_range = "22"
        destination_address_prefix = "192.168.1.0/24"
    }

    security_rule {
        name = "AllowOSClients"
        priority = "200"
        access = "Allow"
        protocol = "Tcp"
        direction = "Inbound"
        source_port_range = "*"
        source_address_prefix = "*"
        destination_port_range = "9200"
        destination_address_prefix = "192.168.1.0/24"
    }

}

resource "azurerm_virtual_network" "i" {
    name = "opensearch"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    address_space = [ "192.168.1.0/24" ]
    subnet {
        address_prefix = "192.168.1.0/24"
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

resource "azurerm_private_dns_zone_virtual_network_link" "i" {
    name = "${azurerm_virtual_network.i.name}-uksouth-host"
    resource_group_name = var.private_dns_link_bink_host[0]
    private_dns_zone_name = var.private_dns_link_bink_host[1]
    virtual_network_id = azurerm_virtual_network.i.id
    registration_enabled = true
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
    size = "Standard_D4as_v4"
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

    custom_data = base64gzip(
        templatefile(
            "${path.root}/init.tmpl",
            {
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[opensearch]"] })),
                cinc_environment = chef_environment.i.name
                cinc_data_secret = ""
            }
        )
    )

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
