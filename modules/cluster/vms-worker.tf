resource "azurerm_availability_set" "worker" {
    name = "${var.cluster_name}-worker-as"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    platform_fault_domain_count = 2
    managed = true

    tags = var.tags
}

variable "pod_ip_configs" {
    default = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30
    ]
}

locals {
    ubuntu_image = {
        "16.04" = [{
            publisher = "Canonical"
            offer = "UbuntuServer"
            sku = "16.04-LTS"
            version = "latest"
        }],
        "20.04" = [{
            publisher = "Canonical"
            offer = "0001-com-ubuntu-server-focal"
            sku = "20_04-lts"
            version = "latest"
        }]
    }
    ubuntu_metadata = {
        "16.04" = null
        "20.04" = "I2Nsb3VkLWNvbmZpZwoKd3JpdGVfZmlsZXM6Ci0gY29udGVudDogfAogICAgZGF0YXNvdXJjZToKICAgICAgQXp1cmU6CiAgICAgICAgYXBwbHlfbmV0d29ya19jb25maWc6IGZhbHNlCiAgb3duZXI6IHJvb3Q6cm9vdAogIHBhdGg6IC9ldGMvY2xvdWQvY2xvdWQuY2ZnLmQvODBfYXp1cmVfbmV0X2NvbmZpZy5jZmcKICBwZXJtaXNzaW9uczogJzA2NDAnCg=="
    }
}

resource "azurerm_network_interface" "worker" {
    count = var.worker_count
    name = format("${var.cluster_name}-worker%02d-nic", count.index)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    depends_on = [azurerm_lb.lb]
    enable_accelerated_networking = true
    enable_ip_forwarding = true

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.worker.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }

    dynamic "ip_configuration" {
        for_each = [for s in var.pod_ip_configs : {
            name = format("pod-%02d", s)
        }]

        content {
            name = ip_configuration.value.name
            subnet_id = azurerm_subnet.worker.id
            private_ip_address_allocation = "Dynamic"
        }
    }
}

resource "azurerm_linux_virtual_machine" "worker" {
    count = var.worker_count
    depends_on = [
        commandpersistence_cmd.certs,
        chef_environment.env,
        azurerm_linux_virtual_machine.controller
    ]

    name = format("${var.cluster_name}-worker%02d", count.index)
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    availability_set_id = azurerm_availability_set.worker.id
    size = var.worker_vm_size
    admin_username = "terraform"
    tags = var.tags

    network_interface_ids = [
        element(azurerm_network_interface.worker.*.id, count.index),
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

    dynamic "source_image_reference" {
        for_each = local.ubuntu_image[var.ubuntu_version]
        content {
            publisher = source_image_reference.value["publisher"]
            offer = source_image_reference.value["offer"]
            sku = source_image_reference.value["sku"]
            version = source_image_reference.value["version"]
        }
    }

    custom_data = local.ubuntu_metadata[var.ubuntu_version]

    provisioner "remote-exec" {
        inline = [
            "sudo reboot"
        ]

        on_failure = continue

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

    # :( 20.04 with "dont use imds network config" takes longer to get an ip and be
    # reachable, so the sleep reduces the number of tries the chef provisioner
    # takes to connect
    provisioner "local-exec" {
        command = "echo 'Waiting for reboot' && sleep 60"
    }

    provisioner "chef" {
        environment = chef_environment.env.name
        client_options = ["chef_license 'accept'"]
        run_list = ["role[worker]"]
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

resource "azurerm_network_interface_backend_address_pool_association" "worker-bap-pools-assoc" {
    count = var.worker_count
    network_interface_id = element(azurerm_network_interface.worker.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.worker_pool.id
    depends_on = [
        azurerm_lb_rule.https,
        azurerm_lb_rule.http
    ]
}
