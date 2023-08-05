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

resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
    name = azurerm_virtual_network.vnet.name
    resource_group_name = var.private_dns.resource_group
    private_dns_zone_name = var.private_dns.primary_zone
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
    for_each = toset(var.private_dns.secondary_zones)
    name = azurerm_virtual_network.vnet.name
    resource_group_name = var.private_dns.resource_group
    private_dns_zone_name = each.key
    virtual_network_id = azurerm_virtual_network.vnet.id
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
        name = "Allow_TCP_22"
        priority = "100"
        access = "Allow"
        protocol = "Tcp"
        direction = "Inbound"
        source_port_range = "*"
        source_address_prefix = "*"
        destination_port_range = "22"
        destination_address_prefix = var.ip_range
    }

    tags = var.tags
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
    load_distribution = "SourceIP"
}

resource "azurerm_lb_backend_address_pool" "pool" {
    name = "pool"
    loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface" "nic" {
    count = 1
    name = format("${var.common_name}%d-nic", count.index)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = false
    depends_on = [
      azurerm_lb.lb
    ]

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "worker-bap-pools-assoc" {
    count = 1
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
    count = 1
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
        caching = "ReadWrite"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 32
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts-gen2"
        version = "latest"
    }

    lifecycle {
        ignore_changes = [custom_data]
    }
}
