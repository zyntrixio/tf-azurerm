resource "azurerm_network_interface" "vault" {
    count = 3
    name = "${format("${azurerm_resource_group.rg.name}-vault-nic-%02d", count.index + 1)}"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "ipconfig"
        subnet_id = "${azurerm_subnet.subnet0.id}"
        private_ip_address_allocation = "Dynamic"
        load_balancer_backend_address_pools_ids = [
            "${azurerm_lb_backend_address_pool.subnet0.id}",
        ]
    }

    tags = {
        environment = "production"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "subnet0" {
    count = 3
    network_interface_id = "${element(azurerm_network_interface.vault.*.id, count.index)}"
    ip_configuration_name = "ipconfig"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.subnet0.id}"
}

resource "azurerm_virtual_machine" "vault" {
    count = 3
    name = "${format("${azurerm_resource_group.rg.name}-vault-vm-%02d", count.index + 1)}"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_interface_ids = [
        "${element(azurerm_network_interface.vault.*.id, count.index)}",
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
        name = "${format("${azurerm_resource_group.rg.name}-vault-disk-%02d", count.index + 1)}"
        disk_size_gb = "32"
        caching = "ReadOnly"
        create_option = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }
    
    os_profile {
        computer_name = "${format("${azurerm_resource_group.rg.name}-vault-vm-%02d", count.index + 1)}"
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


