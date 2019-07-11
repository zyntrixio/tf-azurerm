resource "azurerm_network_interface" "etcd" {
  count = 5
  name = "${format("${azurerm_resource_group.rg.name}-etcd-%02d-nic", count.index + 1)}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  depends_on = ["azurerm_lb.lb"]

  ip_configuration {
    name = "ipconfig"
    subnet_id = "${azurerm_subnet.subnet.2.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_virtual_machine" "etcd" {
  count = 5
  name = "${format("${azurerm_resource_group.rg.name}-etcd-%02d", count.index + 1)}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  network_interface_ids = [
    "${element(azurerm_network_interface.etcd.*.id, count.index)}",
  ]
  vm_size = "${var.etcd_vm_size}"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = false

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name = "${format("${azurerm_resource_group.rg.name}-etcd-%02d-disk", count.index + 1)}"
    disk_size_gb = "32"
    caching = "ReadOnly"
    create_option = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name = "${format("${azurerm_resource_group.rg.name}-etcd-%02d", count.index + 1)}"
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

module "etcd_nsg_rules" {
  source = "../../modules/nsg_rules"
  network_security_group_name = "${azurerm_resource_group.rg.name}-subnet-03-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  rules = [
    {
      name = "AllowAllBastionSubnetTraffic"
      priority = "100"
      source_address_prefix = "${var.subnet_address_prefixes[3]}"
    },
    {
      name = "AllowEtcdClientRequestsWorker"
      priority = "110"
      protocol = "TCP"
      destination_port_range = "2379-2380"
      source_address_prefix = "${var.subnet_address_prefixes[0]}"
    },
    {
      name = "AllowEtcdClientRequestsController"
      priority = "120"
      protocol = "TCP"
      destination_port_range = "2379-2380"
      source_address_prefix = "${var.subnet_address_prefixes[1]}"
    },
#    {
#      name = "BlockEverything"
#      priority = "4096"
#      access = "Deny"
#    }
  ]
}

#resource "azurerm_network_interface_backend_address_pool_association" "etcd-bap-assoc" {
#    count = 2
#    network_interface_id = "${element(azurerm_network_interface.etcd.*.id, count.index)}"
#    ip_configuration_name = "ipconfig"
#    backend_address_pool_id = "${azurerm_lb_backend_address_pool.pools.2.id}"
#}
