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

resource "azurerm_subnet" "subnet" {
    name = "subnet-01"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["192.168.5.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
    name = "chef-nsg"
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
        protocol = "Tcp"
        destination_port_range = 22
        source_port_range = "*"
        destination_address_prefix = "192.168.5.0/24"
        source_address_prefix = "192.168.4.0/24"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowHTTPS"
        priority = 100
        protocol = "Tcp"
        destination_port_range = 443
        source_port_range = "*"
        destination_address_prefix = "192.168.5.0/24"
        source_address_prefix = "*"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowHTTP"
        priority = 110
        protocol = "Tcp"
        destination_port_range = 80
        source_port_range = "*"
        destination_address_prefix = "192.168.5.0/24"
        source_address_prefix = "*"
        direction = "Inbound"
        access = "Allow"
    }
    security_rule {
        name = "AllowToolsPrometheusNodeExporter"
        priority = 130
        protocol = "Tcp"
        destination_port_range = 9100
        source_port_range = "*"
        destination_address_prefix = "192.168.5.0/24"
        source_address_prefix = "10.33.0.0/18"
        direction = "Inbound"
        access = "Allow"
    }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.nsg.id
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

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
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

resource "azurerm_subnet_route_table_association" "rt_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    route_table_id = azurerm_route_table.rt.id
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
        private_ip_address = "192.168.5.4"
        subnet_id = azurerm_subnet.subnet.id
        zones = [ "1", "2", "3" ]
    }

    tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "i" {
    name = "backend"
    loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "http" {
    loadbalancer_id = azurerm_lb.lb.id
    name = "http"
    port = 80
}

resource "azurerm_lb_probe" "https" {
    loadbalancer_id = azurerm_lb.lb.id
    name = "https"
    port = 443
}

resource "azurerm_lb_rule" "http" {
    loadbalancer_id = azurerm_lb.lb.id
    name = "http"
    protocol = "Tcp"
    frontend_port = 80
    backend_port = 80
    frontend_ip_configuration_name = "subnet-01"
    backend_address_pool_ids = [ azurerm_lb_backend_address_pool.i.id ]
    probe_id = azurerm_lb_probe.http.id
}

resource "azurerm_lb_rule" "https" {
    loadbalancer_id = azurerm_lb.lb.id
    name = "https"
    protocol = "Tcp"
    frontend_port = 443
    backend_port = 443
    frontend_ip_configuration_name = "subnet-01"
    backend_address_pool_ids = [ azurerm_lb_backend_address_pool.i.id ]
    probe_id = azurerm_lb_probe.https.id
}

resource "azurerm_network_interface" "i" {
    name = "chef-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = false
    depends_on = [azurerm_lb.lb]

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "i" {
    network_interface_id = azurerm_network_interface.i.id
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.i.id
}

resource "azurerm_linux_virtual_machine" "i" {
    name = "chef"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_B2s"
    admin_username = "terraform"
    network_interface_ids = [
        azurerm_network_interface.i.id,
    ]

    admin_ssh_key {
        username   = "terraform"
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
}
