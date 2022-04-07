resource "azurerm_resource_group" "rg" {
    name = "uksouth-sftp"
    location = "uksouth"
    tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.common_name}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.ip_range]
    tags = var.tags
}

resource "azurerm_subnet" "subnet" {
    name = "subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [
        var.ip_range
    ]
    service_endpoints = [
        "Microsoft.Storage",
        "Microsoft.EventHub",
    ]
}

resource "azurerm_virtual_network_peering" "peer" {
    for_each = var.peers
    name = "local-to-${each.key}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = each.value["vnet_id"]
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "remote_peer" {
    for_each = var.peers
    name = "local-to-${azurerm_resource_group.rg.name}"
    resource_group_name = each.value["resource_group_name"]
    virtual_network_name = each.value["vnet_name"]
    remote_virtual_network_id = azurerm_virtual_network.vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "host" {
    name = "${azurerm_virtual_network.vnet.name}-uksouth-host"
    resource_group_name = var.private_dns_link_bink_host[0]
    private_dns_zone_name = var.private_dns_link_bink_host[1]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = true
}

resource "azurerm_route_table" "rt" {
    name = "${var.common_name}-routes"
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
    name = "${var.common_name}-nsg"
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
        protocol = "Tcp"
        destination_port_range = 22
        source_port_range = "*"
        destination_address_prefix = azurerm_subnet.subnet.address_prefixes[0]
        source_address_prefix = "*"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowNodeExporter"
        priority = 510
        protocol = "Tcp"
        destination_port_range = 9100
        source_port_range = "*"
        destination_address_prefix = azurerm_subnet.subnet.address_prefixes[0]
        source_address_prefix = "*"
        direction = "Inbound"
        access = "Allow"
    }

    tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    log_analytics_workspace_id = var.loganalytics_id

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

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_lb" "lb" {
    name = "${var.common_name}-lb"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"

    frontend_ip_configuration {
        name = "subnet"
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(azurerm_subnet.subnet.address_prefixes[0], 4)
        subnet_id = azurerm_subnet.subnet.id
        zones = [ "1", "2", "3" ]
    }

    tags = var.tags
}

resource "azurerm_lb_probe" "ssh" {
    loadbalancer_id = azurerm_lb.lb.id
    name = "SSH"
    port = 22
}

resource "azurerm_lb_rule" "ssh" {
    loadbalancer_id = azurerm_lb.lb.id
    name = "SSH"
    protocol = "Tcp"
    frontend_port = 22
    backend_port = 22
    frontend_ip_configuration_name = "subnet"
    backend_address_pool_ids = [ azurerm_lb_backend_address_pool.pool.id ]
    probe_id = azurerm_lb_probe.ssh.id
}

resource "azurerm_lb_backend_address_pool" "pool" {
    name = "pool"
    loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface" "nic" {
    count = 2
    name = format("${var.common_name}%d-nic", count.index)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = false

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "worker-bap-pools-assoc" {
    count = 2
    network_interface_id = element(azurerm_network_interface.nic.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
    depends_on = [
        azurerm_lb_rule.ssh,
    ]
}

resource "azurerm_availability_set" "as" {
    name = "${var.common_name}-as"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    platform_fault_domain_count = 2
    managed = true
    tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
    count = 2
    name = format("${var.common_name}%d", count.index)
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_B2s"
    admin_username = "terraform"
    tags = var.tags
    availability_set_id = azurerm_availability_set.as.id
    network_interface_ids = [
        element(azurerm_network_interface.nic.*.id, count.index),
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
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[sftp]"] })),
                cinc_environment = chef_environment.env.name
                cinc_data_secret = ""
            }
        )
    )

    lifecycle {
        ignore_changes = [custom_data]
    }
}
