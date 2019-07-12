resource "azurerm_availability_set" "worker" {
  name = "${var.environment}-worker-as"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count = 2
  managed = true

  tags = {
    environment = "production"
  }
}

variable "pod_ip_configs" {
    default = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30
    ]
}

resource "azurerm_network_interface" "worker" {
  count = "${var.worker_count}"
  name = "${format("${var.environment}-worker-%02d-nic", count.index + 1)}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  enable_accelerated_networking = true
  depends_on = ["azurerm_lb.lb"]

ip_configuration {
      name = "primary"
      subnet_id = "${azurerm_subnet.subnet.0.id}"
      private_ip_address_allocation = "Dynamic"
      primary = true
  }

  dynamic "ip_configuration" {
      for_each = [for s in var.pod_ip_configs: {
          name = "${format("pod-%02d", s)}"
      }]

      content {
          name = ip_configuration.value.name
          subnet_id = "${azurerm_subnet.subnet.0.id}"
          private_ip_address_allocation = "Dynamic"
      }
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_virtual_machine" "worker" {
  count = "${var.worker_count}"
  name = "${format("${var.environment}-worker-%02d", count.index + 1)}"
  location = "${azurerm_resource_group.rg.location}"
  availability_set_id = "${azurerm_availability_set.worker.id}"
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
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name = "${format("${var.environment}-worker-%02d-disk", count.index + 1)}"
    disk_size_gb = "32"
    caching = "ReadOnly"
    create_option = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name = "${format("${var.environment}-worker-%02d", count.index + 1)}"
    admin_username = "laadmin"
    admin_password = "TFB2248hxq!!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "production"
  }
}

module "worker_nsg_rules" {
  source = "../../modules/nsg_rules"
  network_security_group_name = "${var.environment}-subnet-01-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  rules = [
    {
      name = "AllowSSH"
      priority = "100"
      protocol = "TCP"
      destination_port_range = "22"
      source_address_prefix = "192.168.0.0/24"
    },
    {
      name = "AllowAllControllerSubnetTraffic"
      priority = "110"
      source_address_prefix = "${var.subnet_address_prefixes[1]}"
    },
    {
      name = "AllowHttpTraffic"
      priority = "120"
      destination_port_range = "30000"
      protocol = "TCP"
    },
    {
      name = "AllowHttpsTraffic"
      priority = "130"
      destination_port_range = "30001"
      protocol = "TCP"
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

resource "azurerm_network_interface_backend_address_pool_association" "worker-bap-assoc" {
  count = "${var.worker_count}"
  network_interface_id = "${element(azurerm_network_interface.worker.*.id, count.index)}"
  ip_configuration_name = "primary"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.pools.0.id}"
}
