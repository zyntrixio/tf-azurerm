resource "azurerm_lb" "lb" {
    name = "${azurerm_resource_group.rg.name}-lb"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    sku = "Standard"

    frontend_ip_configuration {
        name = "subnet-01"
        private_ip_address_allocation = "Static"
        private_ip_address = "${cidrhost(var.subnet_address_prefixes[0], 4)}"
        subnet_id = "${azurerm_subnet.subnet.0.id}"
    }
    frontend_ip_configuration {
        name = "subnet-02"
        private_ip_address_allocation = "Static"
        private_ip_address = "${cidrhost(var.subnet_address_prefixes[1], 4)}"
        subnet_id = "${azurerm_subnet.subnet.1.id}"
    }
    frontend_ip_configuration {
        name = "subnet-03"
        private_ip_address_allocation = "Static"
        private_ip_address = "${cidrhost(var.subnet_address_prefixes[2], 4)}"
        subnet_id = "${azurerm_subnet.subnet.2.id}"
    }
    frontend_ip_configuration {
        name = "subnet-04"
        private_ip_address_allocation = "Static"
        private_ip_address = "${cidrhost(var.subnet_address_prefixes[3], 4)}"
        subnet_id = "${azurerm_subnet.subnet.3.id}"
    }

    tags = {
        environment = "production"
    }
}

resource "azurerm_lb_backend_address_pool" "pools" {
    count = "${length(var.subnet_address_prefixes)}"
    name = "${format("subnet-%02d", count.index + 1)}"
    loadbalancer_id = "${azurerm_lb.lb.id}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
}

#resource "azurerm_lb_probe" "ssh" {
#    resource_group_name = "${azurerm_resource_group.rg.name}"
#    loadbalancer_id = "${azurerm_lb.lb.id}"
#    name = "ssh-running-probe"
#    port = 22
#}

#resource "azurerm_lb_rule" "ssh" {
#  resource_group_name = "${azurerm_resource_group.rg.name}"
#  loadbalancer_id = "${azurerm_lb.lb.id}"
#  name = "ssh"
#  protocol = "Tcp"
#  frontend_port = 22
#  backend_port = 22
#  frontend_ip_configuration_name = "subnet-04"
#  probe_id = "${azurerm_lb_probe.ssh.id}"
#  backend_address_pool_id = "${azurerm_lb_backend_address_pool.pools.3.id}"
#}
