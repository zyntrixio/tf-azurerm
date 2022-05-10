resource "chef_environment" "env" {
    name = azurerm_resource_group.i.name
}


resource "azurerm_virtual_network" "i" {
    name = "zscaler-vnet"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    address_space = [ var.vnet_cidr ]
    subnet {
        address_prefix = var.vnet_cidr
        name = "subnet"
        security_group = azurerm_network_security_group.i.id
    }
}


resource "azurerm_route_table" "i" {
    name = "zscaler-routes"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    disable_bgp_route_propagation = true

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = "192.168.0.4"
    }

    tags = {
        "Environment" = "zscaler",
    }

}


resource "azurerm_subnet_route_table_association" "i" {
    subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
    route_table_id = azurerm_route_table.i.id
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


resource "azurerm_network_security_group" "i" {
    name = "zcaler-nsg"
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
        destination_address_prefix = "192.168.25.0/24"
    }

}


resource "azurerm_network_interface_security_group_association" "i" {
    network_interface_id = azurerm_network_interface.i.id
    network_security_group_id = azurerm_network_security_group.i.id
}


resource "azurerm_network_interface" "i" {
    name = "zscaler-nic"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location

    ip_configuration {
        name = "internal"
        subnet_id = one(azurerm_virtual_network.i.subnet[*].id)
        private_ip_address_allocation = "Dynamic"
    }
}


resource "azurerm_linux_virtual_machine" "i" {
    name = "zscaler"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    size = "Standard_D2s_v4"
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
        disk_size_gb = 32
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
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["recipe[fury]", "recipe[nebula]"] })),
                cinc_environment = chef_environment.env.name
                cinc_data_secret = ""
            }
        )
    )
}
