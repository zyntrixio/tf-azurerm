resource "azurerm_network_interface" "vault" {
  count = var.vault_count
  name = format("${var.environment}-%02d-nic", count.index + 1)
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_lb.lb]

  ip_configuration {
    name = "primary"
    subnet_id = azurerm_subnet.subnet.0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vault" {
  count = var.vault_count
  name = format("${var.environment}-%02d", count.index + 1)
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    element(azurerm_network_interface.vault.*.id, count.index),
  ]
  vm_size = var.vault_vm_size
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = false

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name = format("${var.environment}-%02d-disk", count.index + 1)
    disk_size_gb = "32"
    caching = "ReadOnly"
    create_option = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name = format("${var.environment}-%02d", count.index + 1)
    admin_username = "laadmin"
    admin_password = "TFB2248hxq!!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}

module "vault_nsg_rules" {
  source = "../../modules/nsg_rules"
  network_security_group_name = "${var.environment}-subnet-01-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  rules = [
    {
      name = "AllowLoadBalancer"
      source_address_prefix = "AzureLoadBalancer"
      priority = "4095"
    },
    {
      name = "BlockEverything"
      priority = "4096"
      access = "Deny"
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
      name = "AllowVaultTrafficProduction"
      priority = "100"
      destination_port_range = "8200"
      protocol = "TCP"
      source_address_prefix = "10.0.0.0/18"
      destination_address_prefix = var.subnet_address_prefixes[0]
    },
    {
      name = "AllowVaultTrafficStage"
      priority = "110"
      destination_port_range = "8200"
      protocol = "TCP"
      source_address_prefix = "10.1.0.0/18"
      destination_address_prefix = var.subnet_address_prefixes[0]
    },
    {
      name = "AllowVaultTrafficDev"
      priority = "120"
      destination_port_range = "8200"
      protocol = "TCP"
      source_address_prefix = "10.2.0.0/18"
      destination_address_prefix = var.subnet_address_prefixes[0]
    }
  ]
}

resource "azurerm_network_interface_backend_address_pool_association" "vault-bap-assoc" {
  count = var.vault_count
  network_interface_id = element(azurerm_network_interface.vault.*.id, count.index)
  ip_configuration_name = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools.0.id
}
