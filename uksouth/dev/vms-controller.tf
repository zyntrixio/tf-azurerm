resource "azurerm_availability_set" "controller" {
  name = "${var.environment}-controller-as"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count = 2
  managed = true

  tags = {
    environment = "development"
  }
}

resource "azurerm_network_interface" "controller" {
  count = "${var.controller_count}"
  name = "${format("${var.environment}-controller-%02d-nic", count.index + 1)}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  depends_on = ["azurerm_lb.lb", "azurerm_lb.plb"]
  enable_accelerated_networking = false

  ip_configuration {
    name = "primary"
    subnet_id = "${azurerm_subnet.subnet.1.id}"
    private_ip_address_allocation = "Dynamic"
    primary = true
  }

  tags = {
    environment = "development"
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
    environment = "development"
  }
}

module "controller_nsg_rules" {
  source = "../../modules/nsg_rules"
  network_security_group_name = "${var.environment}-subnet-02-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
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
      destination_address_prefix = "${var.subnet_address_prefixes[1]}"
      source_address_prefix = "192.168.4.0/24"
    },
    {
      name = "AllowKubeAPIAccessWorkers"
      priority = "100"
      destination_port_range = "6443"
      destination_address_prefix = "${var.subnet_address_prefixes[1]}"
      source_address_prefix = "${var.subnet_address_prefixes[0]}"
    },
    {
      name = "AllowKubeAPIAccessBinkHQ"
      priority = "110"
      destination_port_range = "6443"
      source_address_prefix = "194.74.152.11/32"
    }
  ]
}

module "controller_plb_rules" {
  source = "../../modules/lb_rules"
  loadbalancer_id = "${azurerm_lb.plb.id}"
  backend_id = "${azurerm_lb_backend_address_pool.ppools.1.id}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  frontend_ip_configuration_name = "${azurerm_public_ip.pip.name}"

  lb_port = {
    kube_api = [ "6443", "TCP", "6443" ]
  }
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

module "controller_plb_rules_udp" {
  source = "../../modules/lb_rules_udp"
  loadbalancer_id = "${azurerm_lb.plb.id}"
  backend_id = "${azurerm_lb_backend_address_pool.ppools.1.id}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  frontend_ip_configuration_name = "${azurerm_public_ip.pip.name}"

  lb_port = {
    udphack_controller = ["65533", "UDP", "65533"]
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "controller-bap-ppools-assoc" {
  count = "${var.controller_count}"
  network_interface_id = "${element(azurerm_network_interface.controller.*.id, count.index)}"
  ip_configuration_name = "primary"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.ppools.1.id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "controller-bap-pools-assoc" {
  count = "${var.controller_count}"
  network_interface_id = "${element(azurerm_network_interface.controller.*.id, count.index)}"
  ip_configuration_name = "primary"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.pools.1.id}"
}
