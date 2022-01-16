resource "azurerm_network_interface" "runner" {
    name = "${var.environment}-runner-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = true

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet0.id
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.ip_range, 5)
    }
}

resource "azurerm_linux_virtual_machine" "runner" {
    name = "gitlab-runner"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_D2s_v4"
    admin_username = "terraform"
    tags = var.tags
    network_interface_ids = [
        azurerm_network_interface.runner.id
    ]

    admin_ssh_key {
        username = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadOnly"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 1024
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
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[${chef_role.role.name}]"] })),
                cinc_environment = chef_environment.env.name
                cinc_data_secret = ""
            }
        )
    )

    lifecycle {
        ignore_changes = [custom_data]
    }
}
