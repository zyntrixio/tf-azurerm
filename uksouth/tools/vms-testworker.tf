resource "azurerm_network_interface" "test-worker" {
    name = "${var.environment}-test-worker-00-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    depends_on = [azurerm_lb.lb]
    enable_accelerated_networking = true
    enable_ip_forwarding = true

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.0.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }

    dynamic "ip_configuration" {
        for_each = [for s in var.pod_ip_configs : {
            name = format("pod-%02d", s)
        }]

        content {
            name = ip_configuration.value.name
            subnet_id = azurerm_subnet.subnet.0.id
            private_ip_address_allocation = "Dynamic"
        }
    }
}

resource "azurerm_linux_virtual_machine" "test-worker" {
    depends_on = [commandpersistence_cmd.certs]

    name = "${var.environment}-test-worker-00"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = var.worker_vm_size
    admin_username = "terraform"
    tags = var.tags

    network_interface_ids = [
        azurerm_network_interface.test-worker.id
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

    provisioner "chef" {
        environment = chef_environment.env.name
        client_options = ["chef_license 'accept'"]
        run_list = ["recipe[fury]"]
        node_name = self.name
        server_url = "https://chef.uksouth.bink.sh:4444/organizations/bink"
        recreate_client = true
        user_name = "terraform"
        user_key = file("chef.pem")
        version = "16.5.64"
        ssl_verify_mode = ":verify_peer"
        secret_key = commandpersistence_cmd.databag_secret.result.secret

        connection {
            type = "ssh"
            user = "terraform"
            host = self.private_ip_address
            private_key = file("~/.ssh/id_bink_azure_terraform")
            bastion_host = "ssh.uksouth.bink.sh"
            bastion_user = "terraform"
            bastion_private_key = file("~/.ssh/id_bink_azure_terraform")
        }
    }

    lifecycle {
        ignore_changes = [
            identity
        ]
    }
}
