resource "azurerm_network_interface" "bastion0" {
    name = "${var.environment}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet0.id
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.ip_range, 4)
    }
}

resource "azurerm_linux_virtual_machine" "bastion0" {
    name = "bastion"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = var.bastion_vm_size
    admin_username = "terraform"
    tags = var.tags
    network_interface_ids = [
        azurerm_network_interface.bastion0.id
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

    lifecycle { ignore_changes = [custom_data] }
}
