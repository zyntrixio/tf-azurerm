resource "azurerm_network_interface" "controller" {
    name = "${var.cluster_name}-controller-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = false

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.controller.id
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(azurerm_subnet.controller.address_prefixes[0], 4)
        primary = true
    }
}

resource "azurerm_linux_virtual_machine" "controller" {
    depends_on = [
        commandpersistence_cmd.certs,
        azurerm_virtual_network_peering.peer,
        azurerm_virtual_network_peering.remote_peer,
    ]

    name = "${var.cluster_name}-controller"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = var.controller_vm_size

    network_interface_ids = [
        azurerm_network_interface.controller.id
    ]

    tags = var.tags

    admin_username = "terraform"
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
        run_list = ["role[controller_with_etcd]"]
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
}
