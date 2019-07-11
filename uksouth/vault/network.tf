resource "azurerm_virtual_network" "vnet" {
    name = "${azurerm_resource_group.rg.name}-vnet"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    address_space = ["192.168.1.0/24"]

    tags = {
        environment = "production"
    }
}

resource "azurerm_network_security_group" "subnet0" {
    name = "${azurerm_resource_group.rg.name}-subnet-01-nsg"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

#    security_rule {
#        name = "ssh"
#        priority = 100
#        direction = "Inbound"
#        access = "Allow"
#        protocol = "Tcp"
#        source_port_range = "*"
#        destination_port_range = "*"
#        source_address_prefix = "192.168.0.4/32"
#        destination_address_prefix = "192.168.1.0/25"
#    }

    tags = {
        environment = "production"
    }
}

resource "azurerm_network_security_group" "subnet1" {
    name = "${azurerm_resource_group.rg.name}-subnet-02-nsg"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    tags = {
        environment = "production"
    }
}

resource "azurerm_subnet" "subnet0" {
    name = "subnet-0"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "192.168.1.0/25"
    network_security_group_id = "${azurerm_network_security_group.subnet0.id}"
    route_table_id = "${azurerm_route_table.rt.id}"
}

resource "azurerm_subnet_network_security_group_association" "subnet0" {
    subnet_id = "${azurerm_subnet.subnet0.id}"
    network_security_group_id = "${azurerm_network_security_group.subnet0.id}"
}

resource "azurerm_subnet_route_table_association" "subnet0" {
    subnet_id = "${azurerm_subnet.subnet0.id}"
    route_table_id = "${azurerm_route_table.rt.id}"
}

resource "azurerm_subnet" "subnet1" {
    name = "subnet-1"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "192.168.1.128/25"
    network_security_group_id = "${azurerm_network_security_group.subnet1.id}"
    route_table_id = "${azurerm_route_table.rt.id}"
}

resource "azurerm_subnet_network_security_group_association" "subnet1" {
    subnet_id = "${azurerm_subnet.subnet1.id}"
    network_security_group_id = "${azurerm_network_security_group.subnet1.id}"
}

resource "azurerm_subnet_route_table_association" "subnet1" {
    subnet_id = "${azurerm_subnet.subnet1.id}"
    route_table_id = "${azurerm_route_table.rt.id}"
}

resource "azurerm_virtual_network_peering" "peer" {
    name = "local-to-firewall"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-firewall/providers/Microsoft.Network/virtualNetworks/uksouth-firewall-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_route_table" "rt" {
    name = "${azurerm_resource_group.rg.name}-routes"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = "192.168.0.4"
    }

    tags = {
        environment = "production"
    }
}

resource "azurerm_lb" "lb" {
    name = "${azurerm_resource_group.rg.name}-lb"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    sku = "Standard"

    frontend_ip_configuration {
        name = "subnet0"
        private_ip_address_allocation = "Static"
        private_ip_address = "192.168.1.4"
        subnet_id = "${azurerm_subnet.subnet0.id}"
    }
    frontend_ip_configuration {
        name = "subnet1"
        private_ip_address_allocation = "Static"
        private_ip_address = "192.168.1.132"
        subnet_id = "${azurerm_subnet.subnet1.id}"
    }

    tags = {
        environment = "production"
    }
}

resource "azurerm_lb_backend_address_pool" "subnet0" {
    resource_group_name = "${azurerm_resource_group.rg.name}"
    loadbalancer_id = "${azurerm_lb.lb.id}"
    name = "subnet0"
}

resource "azurerm_lb_backend_address_pool" "subnet1" {
    resource_group_name = "${azurerm_resource_group.rg.name}"
    loadbalancer_id = "${azurerm_lb.lb.id}"
    name = "subnet1"
}
