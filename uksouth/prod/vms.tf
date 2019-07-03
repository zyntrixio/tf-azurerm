resource "azurerm_network_security_rule" "test" {
  name = "ssh"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "192.168.0.4/32"
  destination_address_prefix = "${var.subnet_address_prefixes[3]}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.3.name}"
}

resource "azurerm_network_interface" "bastion" {
    count = 2
    name = "${format("${azurerm_resource_group.rg.name}-bastion-nic-%02d", count.index + 1)}"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "ipconfig"
        subnet_id = "${azurerm_subnet.subnet.3.id}"
        private_ip_address_allocation = "Dynamic"
        load_balancer_backend_address_pools_ids = [
            "${azurerm_lb_backend_address_pool.pools.3.id}",
        ]
    }

    tags = {
        environment = "production"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "bastion-bap-assoc" {
    count = 2
    network_interface_id = "${element(azurerm_network_interface.bastion.*.id, count.index)}"
    ip_configuration_name = "ipconfig"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.pools.3.id}"
}

resource "azurerm_virtual_machine" "bastion" {
    count = 2
    name = "${format("${azurerm_resource_group.rg.name}-bastion-vm-%02d", count.index + 1)}"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_interface_ids = [
        "${element(azurerm_network_interface.bastion.*.id, count.index)}",
    ]
    vm_size = "Standard_B2s"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = false

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name = "${format("${azurerm_resource_group.rg.name}-bastion-disk-%02d", count.index + 1)}"
        disk_size_gb = "32"
        caching = "ReadOnly"
        create_option = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    os_profile {
        computer_name = "${format("${azurerm_resource_group.rg.name}-bastion-vm-%02d", count.index + 1)}"
        admin_username = "laadmin"
        admin_password = "TFB2248hxq!!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "production"
    }
}
