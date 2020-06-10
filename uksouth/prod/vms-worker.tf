resource "azurerm_availability_set" "worker" {
    name = "${var.environment}-worker-as"
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

resource "azurerm_network_interface" "worker" {
    count = var.worker_count
    name = format("${var.environment}-worker-%02d-nic", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    depends_on = [azurerm_lb.lb]
    enable_accelerated_networking = true

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.0.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }

    dynamic "ip_configuration" {
        for_each = [for s in var.pod_ip_configs : {
            name = "${format("pod-%02d", s)}"
        }]

        content {
            name = ip_configuration.value.name
            subnet_id = azurerm_subnet.subnet.0.id
            private_ip_address_allocation = "Dynamic"
        }
    }
}

resource "azurerm_linux_virtual_machine" "worker" {
    count = var.worker_count
    name = format("${var.environment}-worker-%02d", count.index + 1)
    availability_set_id = azurerm_availability_set.worker.id
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    depends_on = [azurerm_network_interface_backend_address_pool_association.worker-bap-assoc]
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
        disk_size_gb = 128
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "16.04-LTS"
        version = "latest"
    }

    provisioner "chef" {
        environment = "uksouth-prod"
        client_options = ["chef_license 'accept'"]
        run_list = ["role[worker]"]
        node_name = self.name
        server_url = "https://chef.uksouth.bink.sh:4444/organizations/bink"
        recreate_client = true
        user_name = "terraform"
        user_key = file("./chef.pem")
        version = "15.9.17"
        ssl_verify_mode = ":verify_peer"
        secret_key = "E9PXP4mDCH16RZIhNAD3CbKnCo/d/dPEROXV/Ui3oL94TqTSiZoBXCpBfUQGA+WzuucfLix8GL/AWlx7hkZMSgzqkielfc/PQ8hH8KGMT8NAiqKRGzxMDgxzCkVrrxqyO1CrH1NNUqbYAWaGNpUghLf62oHs+3ury2+mGuFz7I/F0HsI038uxOQHXhc0GbCWFEYqfm5EW/jPMuHG+3BkUI77c/JFBiEnxF/HtQmpUOtaJprX9B6r6KbGgmiZzn8BCMclWA7FpPME3AhZCyG51hhtzKzP8gyvO6UMrl502KjLaKI0bg9PhTaNcqQeWEVyUNLZLAn4A4bf7aERq5oGiJT7fCoTKVD5LJuko+MpN5P3DQTJMyu6phoPz8Y6zr+EA7Nd3wxbqnjvAJJQxBqKwPimZ8wAv3U03OG/OtnhYgu7Df461HDvABizTTrRJchkwGNMxW0L4KJZt04T313yeJV3FWBRTv/DoWOkxk5jxHYUdHppH5wuyeBJe18GhrfCeR/3gp3kndA7UQypw38ta5McmzFbC6OQym6ovVrRDA3qEiB61QlbhhRsMu/Drgx51lvL5ASBtKjsen+vDmmFHXYFK2aXlEUQFO3aDyzWUDhJyNh0bRi3L8E+FNZAzuhmlihlgLJSVtud9yO55SwSzubkFaNjvaYkkHx9oVXbA40="

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

module "worker_nsg_rules" {
    source = "../../modules/nsg_rules"
    network_security_group_name = "${var.environment}-subnet-01-nsg"
    resource_group_name = azurerm_resource_group.rg.name
    rules = [
        {
            name = "BlockEverything"
            priority = "4096"
            access = "Deny"
        },
        {
            name = "AllowLoadBalancer"
            source_address_prefix = "AzureLoadBalancer"
            priority = "4095"
        },
        {
            name = "AllowSSH"
            priority = "500"
            protocol = "TCP"
            destination_port_range = "22"
            destination_address_prefix = var.subnet_address_prefixes[0]
            source_address_prefix = "192.168.4.0/24"
        },
        {
            name = "AllowAllSubnetTraffic"
            priority = "100"
            source_address_prefix = var.subnet_address_prefixes[0]
            destination_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowAllControllerSubnetTraffic"
            priority = "110"
            source_address_prefix = var.subnet_address_prefixes[1]
            destination_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowHttpTraffic"
            priority = "120"
            destination_port_range = "30000"
            protocol = "TCP"
            destination_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowHttpsTraffic"
            priority = "130"
            destination_port_range = "30001"
            protocol = "TCP"
            destination_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowSftpTraffic"
            priority = "140"
            destination_port_range = "30002"
            protocol = "TCP"
            destination_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowHTTP_PrometheusNodeExporter"
            priority = "150"
            protocol = "TCP"
            destination_port_range = "9100"
            source_address_prefix = "192.168.6.64/28"
            destination_address_prefix = var.subnet_address_prefixes[0]
        }
    ]
}

module "worker_lb_rules" {
    source = "../../modules/lb_rules"
    loadbalancer_id = azurerm_lb.lb.id
    backend_id = azurerm_lb_backend_address_pool.pools.0.id
    resource_group_name = azurerm_resource_group.rg.name
    frontend_ip_configuration_name = "subnet-01"

    lb_port = {
        ingress_http = ["80", "TCP", "30000"]
        ingress_https = ["443", "TCP", "30001"]
        sftp = ["2222", "TCP", "30002"]
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "worker-bap-assoc" {
    count = var.worker_count
    network_interface_id = element(azurerm_network_interface.worker.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pools.0.id
}
