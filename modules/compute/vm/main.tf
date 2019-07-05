resource "azurerm_network_interface" "default" {
    count = var.vm_count
    name = "${format("${var.resource_group_name}-${var.vm_type_name}-%02d-nic", count.index + 1)}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    ip_configuration {
        name = "ipconfig"
        subnet_id = "${var.subnet_id}"
        private_ip_address_allocation = "Dynamic"
#        load_balancer_backend_address_pools_ids = [
#            "${azurerm_lb_backend_address_pool.pools.3.id}",
#        ]
    }
}

resource "azurerm_virtual_machine" "default" {
    count = var.vm_count
    name = "${format("${var.resource_group_name}-${var.vm_type_name}-%02d", count.index + 1)}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    network_interface_ids = [
        "${element(azurerm_network_interface.default.*.id, count.index)}",
    ]
    vm_size = "${var.vm_size}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = false

    storage_image_reference {
        publisher = "${var.os["publisher"]}"
        offer     = "${var.os["offer"]}"
        sku       = "${var.os["sku"]}"
        version   = "${var.os["version"]}"
    }

    storage_os_disk {
        name = "${format("${var.resource_group_name}-${var.vm_type_name}-%02d-disk", count.index + 1)}"
        disk_size_gb = "${var.vm_disk_size}"
        caching = "ReadOnly"
        create_option = "FromImage"
        managed_disk_type = "${var.vm_disk_type}"
    }

    os_profile {
        computer_name  = "${format("${var.resource_group_name}-${var.vm_type_name}-%02d", count.index + 1)}"
        admin_username = "${var.admin["name"]}"
        admin_password = "${var.admin["password"]}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}
