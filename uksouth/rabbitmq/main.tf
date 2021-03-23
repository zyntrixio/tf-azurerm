provider "azurerm" {
    alias = "core"
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
        name = "Allow_LB"
        description = "Allow Healthchecks from Load Balancer"
        access = "Allow"
        priority = 100
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefix = "AzureLoadBalancer"
        source_port_range = "*"
        destination_address_prefix = var.vnet_cidr
        destination_port_ranges = [5671, 15671]
    }

    security_rule {
        name = "Allow_Clustering"
        description = "Allow RabbitMQ nodes to talk to each other"
        access = "Allow"
        priority = 110
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefix = var.vnet_cidr
        source_port_range = "*"
        destination_address_prefix = var.vnet_cidr
        destination_port_ranges = [4369, 5671, 15671, 25672, "35672-35682"]
    }

    security_rule {
        name = "Allow_Clients"
        description = "Allow RabbitMQ Clients to connect to RabbitMQ Server"
        access = "Allow"
        priority = 120
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefixes = var.cluster_cidrs
        source_port_range = "*"
        destination_address_prefix = var.vnet_cidr
        destination_port_ranges = [5671, 15671]
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

resource "azurerm_lb" "i" {
    name = "${azurerm_resource_group.i.name}-lb"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    sku = "Standard"

    frontend_ip_configuration {
        name = "frontend"
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.vnet_cidr, 4)
        subnet_id = azurerm_subnet.i.id
    }

    tags = var.tags
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

resource "azurerm_private_dns_a_record" "i" {
    provider = azurerm.core
    name = "${var.base_name}.uksouth"
    zone_name = var.dns["uksouth_host"].private_dns_zone_name
    resource_group_name = var.dns["uksouth_host"].resource_group_name
    ttl = 300
    records = azurerm_lb.i.private_ip_addresses
}

resource "azurerm_lb_backend_address_pool" "i" {
    name = "rabbits"
    loadbalancer_id = azurerm_lb.i.id
}

resource "azurerm_lb_probe" "amqp" {
    resource_group_name = azurerm_resource_group.i.name
    loadbalancer_id = azurerm_lb.i.id
    name = "amqp"
    port = 5671
}

resource "azurerm_lb_rule" "ampq" {
    resource_group_name = azurerm_resource_group.i.name
    loadbalancer_id = azurerm_lb.i.id
    name = "amqp"
    protocol = "Tcp"
    frontend_port = 5671
    backend_port = 5671
    frontend_ip_configuration_name = "frontend"
    backend_address_pool_id = azurerm_lb_backend_address_pool.i.id
    probe_id = azurerm_lb_probe.amqp.id
}

resource "azurerm_lb_probe" "webui" {
    resource_group_name = azurerm_resource_group.i.name
    loadbalancer_id = azurerm_lb.i.id
    name = "webui"
    port = 15671
}

resource "azurerm_lb_rule" "webui" {
    resource_group_name = azurerm_resource_group.i.name
    loadbalancer_id = azurerm_lb.i.id
    name = "webui"
    protocol = "Tcp"
    frontend_port = 15671
    backend_port = 15671
    frontend_ip_configuration_name = "frontend"
    backend_address_pool_id = azurerm_lb_backend_address_pool.i.id
    probe_id = azurerm_lb_probe.amqp.id
}

resource "azurerm_network_interface" "i" {
    count = var.rabbit_count
    name = format("${var.base_name}%d", count.index)
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    depends_on = [azurerm_lb.i]
    enable_accelerated_networking = true

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.i.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "i" {
    count = var.rabbit_count
    network_interface_id = element(azurerm_network_interface.i.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.i.id
}

resource "azurerm_availability_set" "i" {
    name = "${azurerm_resource_group.i.name}-as"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    platform_fault_domain_count = 2
    managed = true
    tags = var.tags
}

resource "azurerm_linux_virtual_machine" "i" {
    count = var.rabbit_count
    name = format("${var.base_name}%d", count.index)
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    availability_set_id = azurerm_availability_set.i.id
    size = "Standard_D4s_v4"
    admin_username = "terraform"
    network_interface_ids = [
        element(azurerm_network_interface.i.*.id, count.index),
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
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts"
        version   = "latest"
    }

    custom_data = base64gzip(
        templatefile(
            "${path.root}/init.tmpl",
            {
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[rabbitmq]"] })),
                cinc_environment = chef_environment.i.name,
                cinc_data_secret = ""
            }
        )
    )
}
