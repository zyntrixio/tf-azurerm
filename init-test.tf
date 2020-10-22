resource "azurerm_resource_group" "test" {
    name = "test"
    location = "uksouth"
}

resource "azurerm_network_security_group" "test" {
  name = "test-nsg"
  location = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name = "ssh"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "test" {
  name = "vnet-test"
  location = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "test" {
  name = "test"
  resource_group_name = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes = ["192.168.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_public_ip" "test" {
  name = "test"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
  allocation_method = "Static"
}

resource "azurerm_network_interface" "test" {
  name = "test"
  location = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name = "test"
    subnet_id = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name = "test"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
  size = "Standard_D2s_v4"
  admin_username = "laadmin"
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  custom_data = base64gzip(
      templatefile(
          "scripts/init/cloud.tmpl",
          {
              cinc_run_list = "{\\\"run_list\\\":[\\\"recipe[fury]\\\"]}",
              cinc_data_secret = ""
          }
      )
  )

  admin_ssh_key {
    username = "laadmin"
    public_key = file("~/.ssh/id_bink_azure_terraform.pub")
  }

  os_disk {
    caching = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb = 32
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-focal"
    sku = "20_04-lts"
    version = "latest"
  }
}
