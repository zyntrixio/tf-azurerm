resource "azurerm_resource_group" "rg" {
    name = "uksouth-wireguard"
    location = "uksouth"

    tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.ip_range]

    tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "host" {
    name = "${azurerm_virtual_network.vnet.name}-uksouth-host"
    resource_group_name = var.private_dns_link_bink_host[0]
    private_dns_zone_name = var.private_dns_link_bink_host[1]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "sh" {
    name = "${azurerm_virtual_network.vnet.name}-uksouth-sh"
    resource_group_name = var.private_dns_link_bink_sh[0]
    private_dns_zone_name = var.private_dns_link_bink_sh[1]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = false
}

resource "azurerm_network_security_group" "nsg" {
    name = "${var.environment}-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

    security_rule {
        name = "AllowWireGuard"
        description = "WireGuard UDP Access from anywhere"
        access = "Allow"
        priority = 100
        direction = "Inbound"
        protocol = "UDP"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = var.ip_range
        destination_port_ranges = [51820]
    }
    security_rule {
        name = "AllowSSH"
        description = "Allow SSH Access from Bastion Subnet"
        access = "Allow"
        priority = 500
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefix = "192.168.4.0/24"
        source_port_range = "*"
        destination_address_prefix = var.ip_range
        destination_port_range = "22"
    }
    security_rule {
        name = "AllowNodeExporterAccess"
        description = "Tools Prometheus -> Node Exporter"
        access = "Allow"
        priority = 510
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefix = "10.4.0.0/18"
        source_port_range = "*"
        destination_address_prefix = var.ip_range
        destination_port_ranges = [9100]
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

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    log {
        category = "NetworkSecurityGroupEvent"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "NetworkSecurityGroupRuleCounter"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
}

resource "azurerm_route_table" "rt" {
    name = "${var.environment}-routes"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    disable_bgp_route_propagation = true

    tags = var.tags

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = "192.168.0.4"
    }
}

resource "azurerm_subnet" "subnet" {
    name = "subnet0"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.ip_range]
    service_endpoints = [
        "Microsoft.Sql",
    ]
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_virtual_network_peering" "peer" {
    name = "local-to-firewall"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = var.firewall_vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_network_interface" "nic" {
    name = "${var.environment}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    name = "wireguard"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_D2s_v3"
    admin_username = "terraform"
    tags = var.tags
    network_interface_ids = [
        azurerm_network_interface.nic.id
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
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }

    provisioner "chef" {
        environment = "uksouth-wireguard"
        client_options = ["chef_license 'accept'"]
        run_list = ["role[wireguard]"]
        node_name = self.name
        server_url = "https://chef.uksouth.bink.sh:4444/organizations/bink"
        recreate_client = true
        user_name = "terraform"
        user_key = file("./chef.pem")
        version = "15.9.17"
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
