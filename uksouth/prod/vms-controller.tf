resource "azurerm_availability_set" "controller" {
  name = "${var.environment}-controller-as"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count = 2
  managed = true

  tags = {
    environment = "production"
  }
}

resource "azurerm_network_interface" "controller" {
  count = "${var.controller_count}"
  name = "${format("${var.environment}-controller-%02d-nic", count.index + 1)}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  enable_accelerated_networking = true
  depends_on = ["azurerm_lb.lb"]

  ip_configuration {
    name = "primary"
    subnet_id = "${azurerm_subnet.subnet.1.id}"
    private_ip_address_allocation = "Dynamic"
    primary = true
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_virtual_machine" "controller" {
  count = "${var.controller_count}"
  name = "${format("${var.environment}-controller-%02d", count.index + 1)}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  availability_set_id = "${azurerm_availability_set.controller.id}"
  network_interface_ids = [
    "${element(azurerm_network_interface.controller.*.id, count.index)}",
  ]
  vm_size = "${var.controller_vm_size}"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = false

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name = "${format("${var.environment}-controller-%02d-disk", count.index + 1)}"
    disk_size_gb = "32"
    caching = "ReadOnly"
    create_option = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name = "${format("${var.environment}-controller-%02d", count.index + 1)}"
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

module "controller_nsg_rules" {
  source = "../../modules/nsg_rules"
  network_security_group_name = "${var.environment}-subnet-02-nsg"
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
      name = "AllowAllEtcdSubnetTraffic"
      priority = "110"
      source_address_prefix = "${var.subnet_address_prefixes[2]}"
    },
    {
      name = "AllowKubectl"
      priority = "120"
      destination_port_range = "6443"
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

module "controller_lb_rules" {
  source = "../../modules/lb_rules"
  loadbalancer_id = "${azurerm_lb.lb.id}"
  backend_id = "${azurerm_lb_backend_address_pool.pools.1.id}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  frontend_ip_configuration_name = "subnet-02"

  lb_port = {
    kube_api = [ "6443", "TCP", "6443" ]
  }
}

module "controller_lb_rules_udp" {
  source = "../../modules/lb_rules_udp"
  loadbalancer_id = "${azurerm_lb.lb.id}"
  backend_id = "${azurerm_lb_backend_address_pool.pools.1.id}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  frontend_ip_configuration_name = "subnet-02"

  lb_port = {
    udphack_controller = ["65533", "UDP", "65533"]
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "controller-bap-assoc" {
  count = "${var.controller_count}"
  network_interface_id = "${element(azurerm_network_interface.controller.*.id, count.index)}"
  ip_configuration_name = "primary"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.pools.1.id}"
}
