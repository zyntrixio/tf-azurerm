terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
        chef = {
            source = "terrycain/chef"
        }
    }
    required_version = ">= 0.13"
}

resource "azurerm_resource_group" "ii" {
    name = "uksouth-${var.environment}"
    location = "uksouth"

    tags = var.tags
}

resource "chef_environment" "ii" {
    name = azurerm_resource_group.ii.name
}

resource "chef_role" "ii" {
  name = var.environment
  run_list = [
    "recipe[fury]",
    "recipe[pepper]",
  ]
}

resource "azurerm_virtual_network" "ii" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.ii.location
    resource_group_name = azurerm_resource_group.ii.name
    address_space = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "ii" {
    name = "subnet"
    resource_group_name = azurerm_resource_group.ii.name
    virtual_network_name = azurerm_virtual_network.ii.name
    address_prefixes = ["192.168.0.0/24"]
}

resource "azurerm_public_ip" "ii" {
    count = 2
    name = "${var.environment}-${count.index}"
    resource_group_name = azurerm_resource_group.ii.name
    location = azurerm_resource_group.ii.location
    ip_version = "IPv4"
    allocation_method = "Static"
    sku = "Standard"

    tags = var.tags
}

resource "azurerm_network_interface" "ii" {
    count = 2
    name = "${var.environment}-${count.index}"
    location = azurerm_resource_group.ii.location
    resource_group_name = azurerm_resource_group.ii.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.ii.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.ii[count.index].id
    }
}

resource "azurerm_network_security_group" "ii" {
    count = 2
    name = "${var.environment}-${count.index}"
    location = azurerm_resource_group.ii.location
    resource_group_name = azurerm_resource_group.ii.name

    security_rule {
        name = "dns-tcp"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "53"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name = "dns-udp"
        priority = 101
        direction = "Inbound"
        access = "Allow"
        protocol = "Udp"
        source_port_range = "*"
        destination_port_range = "53"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name = "ssh-tcp"
        priority = 102
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefixes = var.secure_origins
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface_security_group_association" "ii" {
    count = 2
    network_interface_id = azurerm_network_interface.ii[count.index].id
    network_security_group_id = azurerm_network_security_group.ii[count.index].id
}

resource "azurerm_linux_virtual_machine" "ii" {
    count = 2
    name = "${var.environment}-${count.index}"
    resource_group_name = azurerm_resource_group.ii.name
    location = azurerm_resource_group.ii.location
    size = "Standard_B1s"
    admin_username = "terraform"
    network_interface_ids = [
        azurerm_network_interface.ii[count.index].id,
    ]

    admin_ssh_key {
        username = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-focal"
        sku = "20_04-lts"
        version = "latest"
    }

    custom_data = base64gzip(
        templatefile(
            "${path.root}/init.tmpl",
            {
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[${chef_role.ii.name}]"] })),
                cinc_environment = chef_environment.ii.name
                cinc_data_secret = ""
            }
        )
    )

    lifecycle {
        ignore_changes = [custom_data]
    }
}
