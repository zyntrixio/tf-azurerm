resource "azurerm_network_interface" "xxxlarge-worker" {
    count = var.xxxlarge_worker_count
    name = format("${var.environment}-worker-xxxlarge-%02d-nic", count.index + 1)
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

resource "azurerm_network_interface_backend_address_pool_association" "xxxlarge-worker-bap-pools-assoc" {
    count = var.xxxlarge_worker_count
    network_interface_id = element(azurerm_network_interface.xxxlarge-worker.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pools.0.id
}

resource "azurerm_linux_virtual_machine" "xxxlarge-worker" {
    count = var.xxxlarge_worker_count
    name = format("${var.environment}-xxxlarge-worker-%02d", count.index + 1)
    availability_set_id = azurerm_availability_set.worker.id
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    depends_on = [azurerm_network_interface_backend_address_pool_association.worker-bap-pools-assoc]
    size = var.xxxlarge_worker_vm_size
    admin_username = "terraform"
    tags = var.tags

    network_interface_ids = [
        element(azurerm_network_interface.xxxlarge-worker.*.id, count.index),
    ]

    admin_ssh_key {
        username = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadOnly"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 128
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "16.04-LTS"
        version = "latest"
    }

    provisioner "chef" {
        environment = "uksouth-sandbox"
        client_options = ["chef_license 'accept'"]
        run_list = ["role[worker]"]
        node_name = self.name
        server_url = "https://chef.uksouth.bink.sh:4444/organizations/bink"
        recreate_client = true
        user_name = "terraform"
        user_key = file("./chef.pem")
        version = "16.5.64"
        ssl_verify_mode = ":verify_peer"
        secret_key = "7y0sKw2XMCudEQ3ljZOx/Dc8bfa3VS6QRzOyuZ7tFROiFQWkEburURDwN0gzo98dAoAbi+UW4Q2AWEBNrLkTpAvuFjAphXoE32jmifjVCR+7MxKkw/QLwSs1LlDHW9qkZJyfyXH7c1ZNy/r4k6UcgxJhlVLkIjlU07HVfQPVhHlT7PjjlkGlosfAQWsX1EzoCn5Sq/aK4mhVnsFVAKIevFMveH3LOBYJ+BzeL7YoGcePWTNrfme5BPkx1kHG8N4AIinM/YSnDFa8J6i18PbHC1JPhxve3ERoMrkgk5jE+N4Yz9M2+d3u8tTvMP+GWeYz1PhJ9Uc+3i7YdciCXuqeq/igAphuXQzyhs4fJnubOfWlYJeuzcoRa5vfemaVboc6/TE7+ZX8Fk+48Z56EFmmKv+RVMz8hd1BKULRfvPtfZ7Uznx7J3ybg0ooRedaY19E/w8UOH7L6g7ymgwC2X2RKpZCJHo6P35h/qbvEEfm7ZFu8yqKgrvSKf0a8lBba2tMwvAtlAV9CZBeoTWZrvLqJntcE0TJTvjFSygUy2xRtWKq85vP2JP7RgSwQrU6lBZFRWmqnmt+TWxwajtLQtNybpeSjJYT7xG9sMHRyX+8Y3FVlaDak2WqVus5OjZDpkeS0w3KzPJxsG6pfxoaDz8CTljEWV8r0wpfjZxjc4C0r3k="

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
