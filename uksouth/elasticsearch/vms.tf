resource "azurerm_availability_set" "elasticsearch" {
    name = "${var.environment}-elasticsearch"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    platform_fault_domain_count = 2
    managed = true
    tags = var.tags
}

resource "azurerm_network_interface" "elasticsearch" {
    count = var.cluster_size
    name = format("${var.environment}-elasticsearch-%02d-nic", count.index)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    depends_on = [azurerm_lb.lb]

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "elasticsearch-bap-pools-assoc" {
    count = var.cluster_size
    network_interface_id = element(azurerm_network_interface.elasticsearch.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}

resource "azurerm_linux_virtual_machine" "elasticsearch" {
    count = var.cluster_size
    name = format("${var.environment}-%02d", count.index)
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    availability_set_id = azurerm_availability_set.elasticsearch.id
    size = var.vm_size
    admin_username = "terraform"
    tags = var.tags

    network_interface_ids = [
        element(azurerm_network_interface.elasticsearch.*.id, count.index),
    ]

    admin_ssh_key {
        username = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadOnly"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 2048
    }

    # Canonical are being whimps and not pointing 20.04-LTS to an actual image as they're
    # scared about people complaining about python3.8
    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-focal"
        sku = "20_04-lts"
        version = "latest"
    }

    provisioner "chef" {
        environment = chef_environment.env.name
        client_options = ["chef_license 'accept'"]
        run_list = ["role[elasticsearch]"]
        node_name = self.name
        server_url = "https://chef.uksouth.bink.sh:4444/organizations/bink"
        recreate_client = true
        user_name = "terraform"
        user_key = file("chef.pem")
        version = "16.5.64"
        ssl_verify_mode = ":verify_peer"
        secret_key = "l/iAhIHQeM4UtimiQQrX+EtECAvfEfw9zgpadPrzhmhlbHB3eLhwGdXPsKVlbOpPn/b7XGECtQaodKdaMVdpJ9qyT6v3X3AD8XzliI6Z0wgHT8ZHN9RaOveLSpeAZt/XXG6RJcCGQEyqTM9RYckz6d7VSuKdeP2XyuU3i7o2BvlMTw8txaB9eCCAWYKAx7aPiimeVZQ3FnlNgMoORvS8NvtifCG/5TC6Y4Wv8ZM4cqD+RfUjHfjFzNI7gla6/XLcXCX25UbROOFBckL+FRn8FIubSQv8JSGUYUiS4TAadyMQAs+Qjg+vENNVbB85tCyOE714WdlhSN5h1VoLoc1MqKqj4VS+s58bc6tQn1hYHLeLd0bXHzUUVTpijkyRGH9RbVeJqMMXIVR/mpF8sNYhAzLiLjKx92LQUuxCltzEUDm6f0VS1AIlnIcNgSLI4+rKhpq+osZfe9R6vmmnK7w24v6Fpiag5ShKmkCy1AwYfIEzf+0s0zCBc5kpPpkTls7pPu85vDz9sPWqUb7SX2yurNkzJlqYcmChMgj3PG/QKx0STXF4y7E+g+yX5LrMWuGWhJ/rzAn8ug29BaKeKOfuThZx01vNz3iymDT90W2oz4kIwa+FNc5dZcSHn+kgv213KR7KMrCvRw2MYyjxfpcj1zkZ5MTacPBemYn/j3No2BY="

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
        ignore_changes = [source_image_reference]
    }
}

module "elasticsearch_nsg_rules" {
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
            source_address_prefix = "192.168.4.0/24"
            destination_address_prefix = var.address_space
        },
        {
            name = "AllowElasticsearchTrafficElasticsearch"
            priority = "100"
            destination_port_range = "9300"
            protocol = "TCP"
            source_address_prefix = var.address_space
            destination_address_prefix = var.address_space
        },
        {
            name = "AllowElasticsearchTrafficFromAll"
            priority = "120"
            destination_port_range = "9200"
            protocol = "TCP"
            source_address_prefix = "10.0.0.0/8"
            destination_address_prefix = var.address_space
        },
        {
            name = "AllowHTTP_PrometheusNodeExporter"
            priority = "160"
            protocol = "TCP"
            destination_port_range = "9100"
            source_address_prefix = "10.33.0.0/18"
            destination_address_prefix = var.address_space
        },
        {
            name = "AllowElasticsearchTrafficBastion"
            priority = "180"
            destination_port_range = "9200"
            protocol = "TCP"
            source_address_prefix = "192.168.4.0/24"
            destination_address_prefix = var.address_space
        },
        {
            name = "AllowElasticsearchTrafficOLDElasticsearch"
            priority = "190"
            destination_port_range = "9200"
            protocol = "TCP"
            source_address_prefix = "192.168.6.0/24"
            destination_address_prefix = var.address_space
        },
    ]
}

module "elasticsearch_lb_rules" {
    source = "../../modules/lb_rules"
    loadbalancer_id = azurerm_lb.lb.id
    backend_id = azurerm_lb_backend_address_pool.pool.id
    resource_group_name = azurerm_resource_group.rg.name
    frontend_ip_configuration_name = "subnet-01"

    lb_port = {
        elasticsearch = ["9200", "TCP", "9200"]
    }
}
