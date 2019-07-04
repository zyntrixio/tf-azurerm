module "bastion" {
  source              = "../../modules/compute"
  vm_count            = 2
  resource_group_name = "${azurerm_resource_group.rg.name}"
  subnet_id           = "${azurerm_subnet.subnet.3.id}"
  vm_type_name        = "bastion"
  location            = "${azurerm_resource_group.rg.location}"
  vm_disk_size        = "32"
  vm_size             = "Standard_B2s"
  lb_backend_address_pool_id_list = "${azurerm_lb_backend_address_pool.pools.3.id}"
}
