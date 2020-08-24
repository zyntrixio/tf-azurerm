provider "azurerm" {
    alias = "core"
}

resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
    tags = var.tags
}

resource "azurerm_role_assignment" "iam" {
    for_each = var.resource_group_iam

    scope = azurerm_resource_group.rg.id
    role_definition_name = each.value["role"]
    principal_id = each.value["object_id"]
}

resource "azurerm_virtual_network" "vnet" {
    name = "${azurerm_resource_group.rg.name}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.vnet_cidr]
    tags = var.tags
}

resource "azurerm_subnet" "subnet" {
    name = "subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [
        var.vnet_cidr
    ]
    service_endpoints = [
        "Microsoft.Storage",
    ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
    for_each = var.private_dns

    provider = azurerm.core

    name = "${azurerm_virtual_network.vnet.name}-${each.key}"
    resource_group_name = each.value["resource_group_name"]
    private_dns_zone_name = each.value["private_dns_zone_name"]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = each.value["should_register"]
}

resource "azurerm_route_table" "rt" {
    name = "${azurerm_resource_group.rg.name}-routes"
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

resource "azurerm_subnet_route_table_association" "route_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_network_security_group" "nsg" {
    name = "${azurerm_resource_group.rg.name}-nsg"
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
        name = "AllowSSH"
        priority = 500
        protocol = "TCP"
        destination_port_range = 22
        source_port_range = "*"
        destination_address_prefix = azurerm_subnet.subnet.address_prefixes[0]
        source_address_prefixes = ["192.168.0.0/24", "192.168.4.0/24"]
        direction = "Inbound"
        access = "Allow"
    }

    tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_network_peering" "source" {
    for_each = var.peers

    name = "local-to-${each.key}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = each.value["vnet_id"]
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "remote" {
    for_each = var.peers

    provider = azurerm.core

    name = "local-to-${azurerm_resource_group.rg.name}"
    resource_group_name = each.value["resource_group_name"]
    virtual_network_name = each.value["vnet_name"]
    remote_virtual_network_id = azurerm_virtual_network.vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_network_interface" "nic" {
    name = "${azurerm_resource_group.rg.name}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = false

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(azurerm_subnet.subnet.address_prefixes[0], 4)
        primary = true
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    depends_on = [
        azurerm_virtual_network_peering.source,
        azurerm_virtual_network_peering.remote,
    ]

    name = "${azurerm_resource_group.rg.name}-vm"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_B1s"

    network_interface_ids = [
        azurerm_network_interface.nic.id
    ]

    tags = var.tags

    admin_username = "terraform"
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

    provisioner "chef" {
        environment = chef_environment.env.name
        client_options = ["chef_license 'accept'"]
        run_list = ["role[sftp]"]
        node_name = self.name
        server_url = "https://chef.uksouth.bink.sh:4444/organizations/bink"
        recreate_client = true
        user_name = "terraform"
        user_key = file("chef.pem")
        version = "16.4.41"
        ssl_verify_mode = ":verify_peer"

        connection {
            type = "ssh"
            user = "terraform"
            host = self.private_ip_address
            private_key = file("~/.ssh/id_bink_azure_terraform")
            bastion_host = "ssh.uksouth.bink.sh"
            bastion_user = "terraform"
            bastion_private_key = file("~/.ssh/id_bink_azure_terraform")
        }
    }
}

resource "azurerm_firewall_nat_rule_collection" "ingress" {
    provider = azurerm.core

    name = "ingress-${azurerm_resource_group.rg.name}"
    azure_firewall_name = var.firewall.firewall_name
    resource_group_name = var.firewall.resource_group_name
    priority = var.firewall.ingress_priority
    action = "Dnat"

    rule {
        name = "sftp"
        source_addresses = [var.firewall.ingress_source]
        destination_ports = [var.firewall.ingress_sftp]
        destination_addresses = [var.firewall.public_ip]
        translated_address = azurerm_network_interface.nic.private_ip_address
        translated_port = "22"
        protocols = ["TCP"]
    }
}
