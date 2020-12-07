resource "azurerm_resource_group" "rg" {
    name = "${var.location}-chef"
    location = var.location

    tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["192.168.5.0/24"]

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

resource "azurerm_subnet" "subnet" {
    count = length(var.subnet_address_prefixes)
    name = format("subnet-%02d", count.index + 1)
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [element(var.subnet_address_prefixes, count.index)]
}

resource "azurerm_network_security_group" "nsg" {
    count = length(var.subnet_address_prefixes)
    name = format("${var.environment}-subnet-%02d-nsg", count.index + 1)
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
        name = "AllowLoadBalancer"
        protocol = "*"
        source_address_prefix = "AzureLoadBalancer"
        source_port_range = "*"
        destination_port_range = "*"
        destination_address_prefix = "*"
        priority = 4095
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowSSH"
        priority = 500
        protocol = "TCP"
        destination_port_range = 22
        source_port_range = "*"
        destination_address_prefix = var.subnet_address_prefixes[0]
        source_address_prefix = "192.168.4.0/24"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowHTTPS"
        priority = 100
        protocol = "TCP"
        destination_port_range = 4444
        source_port_range = "*"
        destination_address_prefix = var.subnet_address_prefixes[0]
        source_address_prefix = "*"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowToolsPrometheusNodeExporter"
        priority = 110
        protocol = "TCP"
        destination_port_range = 9100
        source_port_range = "*"
        destination_address_prefix = var.subnet_address_prefixes[0]
        source_address_prefix = "10.33.0.0/18"
        direction = "Inbound"
        access = "Allow"
    }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    count = length(var.subnet_address_prefixes)
    name = "binkuksouthlogs"
    target_resource_id = element(azurerm_network_security_group.nsg.*.id, count.index)
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

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    count = length(var.subnet_address_prefixes)
    subnet_id = element(azurerm_subnet.subnet.*.id, count.index)
    network_security_group_id = element(azurerm_network_security_group.nsg.*.id, count.index)
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
    count = length(var.subnet_address_prefixes)
    subnet_id = element(azurerm_subnet.subnet.*.id, count.index)
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_route_table" "rt" {
    name = "${var.environment}-routes"
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

resource "azurerm_virtual_network_peering" "peer" {
    name = "local-to-firewall"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-firewall/providers/Microsoft.Network/virtualNetworks/firewall-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_lb" "lb" {
    name = "${var.environment}-lb"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"

    frontend_ip_configuration {
        name = "subnet-01"
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.subnet_address_prefixes[0], 4)
        subnet_id = azurerm_subnet.subnet.0.id
    }

    tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "pools" {
    count = length(var.subnet_address_prefixes)
    name = format("subnet-%02d", count.index + 1)
    loadbalancer_id = azurerm_lb.lb.id
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "chef" {
    name = "chef-01-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = false
    depends_on = [azurerm_lb.lb]

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.0.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "chef-bap-assoc" {
    network_interface_id = azurerm_network_interface.chef.id
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pools.0.id
}

resource "azurerm_lb_probe" "https" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "https-probe"
    port = 4444
}

resource "azurerm_lb_rule" "https" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "HTTPS"
    protocol = "Tcp"
    frontend_port = 4444
    backend_port = 4444
    frontend_ip_configuration_name = "subnet-01"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pools.0.id
    probe_id = azurerm_lb_probe.https.id
}

resource "azurerm_virtual_machine" "chef" {
    name = "chef-01"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.chef.id]

    vm_size = "Standard_B2s"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = false

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = "chef-01-disk"
        disk_size_gb = "32"
        caching = "ReadOnly"
        create_option = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    os_profile {
        computer_name = "chef-01"
        admin_username = "terraform"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path = "/home/terraform/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrdSta+Sv3YWupzHk4U1VS7jvUvkQgmWexanDnGHLx7YjBKxi1tuhE0WgzgkbB3WqDNLrj5dXdv9la8S9VvrL1L1r4YG+5N0f6Ri1xE+cGei6aFAm57eLPnGhAY6lxiPSx79x+cfmW0YdZHI/6rb4Gix+KoH4BOPZnshxjoyL5MJpel2/5LZHWuazT3ihzWXemhMQ11mXJGot+tuVRB3tkVg+vi//YyRo5vKQSjpvirrP8MgQY76jk0RzxhwsP1d+7lkeAcedPilNpmhP72rfWMTxkrbO7XQrZMpIeL7qywdaOb0tPEB0n9KscUwiMvM4oOLVizsgzKoUOZ91rkxhb id_bink_azure_terraform"
        }
    }

    tags = var.tags
}
