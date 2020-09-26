resource "azurerm_availability_set" "controller" {
    name = "${var.environment}-controller-as"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    platform_fault_domain_count = 2
    managed = true

    tags = var.tags
}

resource "azurerm_network_interface" "controller" {
    count = var.controller_count
    name = format("${var.environment}-controller-%02d-nic", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    depends_on = [azurerm_lb.lb]
    enable_accelerated_networking = false

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.1.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }
}

resource "azurerm_linux_virtual_machine" "controller" {
    count = var.controller_count
    depends_on = [commandpersistence_cmd.certs]

    name = format("${var.environment}-controller-%02d", count.index + 1)
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    availability_set_id = azurerm_availability_set.controller.id
    size = var.controller_vm_size

    network_interface_ids = [
        element(azurerm_network_interface.controller.*.id, count.index),
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
        offer = "UbuntuServer"
        sku = "16.04-LTS"
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


module "controller_nsg_rules" {
    source = "../../modules/nsg_rules"
    network_security_group_name = "${var.environment}-subnet-02-nsg"
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
            destination_address_prefix = var.subnet_address_prefixes[1]
            source_address_prefix = "192.168.4.0/24"
        },
        {
            name = "AllowKubeAPIAccessWorkers"
            priority = "100"
            destination_port_range = "6443"
            destination_address_prefix = var.subnet_address_prefixes[1]
            source_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowKubeAPIAccessFirewall"
            priority = "110"
            destination_port_range = "6443"
            # source_address_prefix = "192.168.0.4/32" # TODO: Need to figure this out
            destination_address_prefix = var.subnet_address_prefixes[1]
        },
        {
            name = "AllowHTTP_PrometheusNodeExporter"
            priority = "120"
            protocol = "TCP"
            destination_port_range = "9100"
            source_address_prefix = "192.168.6.64/28"
            destination_address_prefix = var.subnet_address_prefixes[1]
        },
        {
            name = "AllowToolsPrometheusNodeExporter"
            priority = "130"
            protocol = "TCP"
            destination_port_range = "9100"
            source_address_prefix = var.subnet_address_prefixes[0]
            destination_address_prefix = var.subnet_address_prefixes[1]
        }
    ]
}

module "controller_lb_rules" {
    source = "../../modules/lb_rules"
    loadbalancer_id = azurerm_lb.lb.id
    backend_id = azurerm_lb_backend_address_pool.pools.1.id
    resource_group_name = azurerm_resource_group.rg.name
    frontend_ip_configuration_name = "subnet-02"

    lb_port = {
        kube_api = ["6443", "TCP", "6443"]
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "controller-bap-pools-assoc" {
    count = var.controller_count
    network_interface_id = element(azurerm_network_interface.controller.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pools.1.id
}
