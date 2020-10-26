resource "azurerm_resource_group" "rg" {
    name = "uksouth-mastercard"
    location = "uksouth"
}

resource "azurerm_public_ip" "ip" {
    name = "${azurerm_resource_group.rg.name}-pip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Static"
}

resource "azurerm_network_security_group" "nsg" {
    name = "${azurerm_resource_group.rg.name}-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
    name = "${azurerm_resource_group.rg.name}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "subnet" {
    name = "subnet0"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["192.168.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
    name = "${azurerm_resource_group.rg.name}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.ip.id
    }
}

resource "azurerm_network_security_rule" "rdp" {
    name = "Remote Desktop"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefixes = [
        "194.74.152.11/32", # Ascot Bink HQ
        "217.169.3.233/32", # cpressland@bink.com
        "81.2.99.144/29", # cpressland@bink.com
        "82.13.29.15/32", # twinchester@bink.com
        "82.24.92.107/32", # tcain@bink.com
    ]
    destination_address_prefixes = [azurerm_public_ip.ip.ip_address, azurerm_network_interface.nic.private_ip_address]
    resource_group_name = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_windows_virtual_machine" "vm" {
    name = "${azurerm_resource_group.rg.name}-vm"
    computer_name = "mastercard-vm"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_D2s_v4"
    admin_username = "laadmin"
    admin_password = "TFB2248hxq!!"
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 128
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2019-Datacenter"
        version = "latest"
    }

    lifecycle {
        ignore_changes = [source_image_reference]
    }
}
