resource "azurerm_network_interface" "worker" {
    count = 3
    name = "${format("${azurerm_resource_group.rg.name}-worker-%02d-nic", count.index + 1)}"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    enable_accelerated_networking = true

    ip_configuration {
        name = "ipconfig"
        subnet_id = "${azurerm_subnet.subnet.0.id}"
        private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = "staging"
    }
}

resource "azurerm_virtual_machine" "worker" {
    count = 3
    name = "${format("${azurerm_resource_group.rg.name}-worker-%02d", count.index + 1)}"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_interface_ids = [
        "${element(azurerm_network_interface.worker.*.id, count.index)}",
    ]
    vm_size = "${var.worker_vm_size}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = false

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name = "${format("${azurerm_resource_group.rg.name}-worker-%02d-disk", count.index + 1)}"
        disk_size_gb = "32"
        caching = "ReadOnly"
        create_option = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    os_profile {
        computer_name = "${format("${azurerm_resource_group.rg.name}-worker-%02d", count.index + 1)}"
        admin_username = "laadmin"
        admin_password = "TFB2248hxq!!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "staging"
    }
}

module "worker_nsg_rules" {
  source = "../../modules/nsg_rules"
  network_security_group_name = "${azurerm_resource_group.rg.name}-subnet-01-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  rules = [
    {
      name = "AllowAllControllerSubnetTraffic"
      priority = "100"
      source_address_prefix = "${var.subnet_address_prefixes[1]}"
    },
    {
      name = "AllowHttpTraffic"
      priority = "110"
      destination_port_range = "30000"
      protocol = "TCP"
    },
    {
      name = "AllowHttpsTraffic"
      priority = "120"
      destination_port_range = "30001"
      protocol = "TCP"
    },
    {
      name = "AllowSSH"
      priority = "130"
      protocol = "TCP"
      destination_port_range = "22"
    },
    {
      name = "AllowLoadBalancer"
      source_address_prefix = "AzureLoadBalancer"
      priority = "4095"
    },
    {
      name = "BlockEverything"
      priority = "4096"
      access = "Deny"
    }
  ]
}

module "worker_lb_rules" {
  source = "../../modules/lb_rules"
  loadbalancer_id = "${azurerm_lb.lb.id}"
  backend_id = "${azurerm_lb_backend_address_pool.pools.0.id}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  frontend_ip_configuration_name = "subnet-01"

  lb_port = {
    ingress_http = [ "80", "TCP", "30000" ]
    ingress_https = [ "443", "TCP", "30001" ]
  }
}

module "worker_lb_rules_udp" {
  source = "../../modules/lb_rules_udp"
  loadbalancer_id = "${azurerm_lb.lb.id}"
  backend_id = "${azurerm_lb_backend_address_pool.pools.0.id}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  frontend_ip_configuration_name = "subnet-01"

  lb_port = {
    udphack_worker = ["65532", "UDP", "65532"]
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "worker-bap-assoc" {
    count = 3
    network_interface_id = "${element(azurerm_network_interface.worker.*.id, count.index)}"
    ip_configuration_name = "ipconfig"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.pools.0.id}"
}
