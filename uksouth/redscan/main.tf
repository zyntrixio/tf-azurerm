variable "bink_sh" {}
variable "dns_link" {}
variable "secure_origins" {}

resource "azurerm_resource_group" "rg" {
    name = "uksouth-redscan"
    location = "uksouth"
}

resource "azurerm_public_ip" "ip" {
    name = "${azurerm_resource_group.rg.name}-pip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Static"
}

resource "azurerm_dns_a_record" "a" {
    name = "redscan.uksouth.bink.sh"
    zone_name = var.bink_sh[1]
    resource_group_name = var.bink_sh[0]
    ttl = 300
    records = [azurerm_public_ip.ip.ip_address]
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
    address_space = ["192.168.0.0/24"] # Use Azure Firewall space to avoid it being connected in future
}

resource "azurerm_private_dns_zone_virtual_network_link" "host" {
    name = "${azurerm_virtual_network.vnet.name}-uksouth-host"
    resource_group_name = var.dns_link[0]
    private_dns_zone_name = var.dns_link[1]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = false
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
    source_address_prefixes = var.secure_origins
    destination_address_prefixes = [azurerm_public_ip.ip.ip_address, azurerm_network_interface.nic.private_ip_address]
    resource_group_name = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_windows_virtual_machine" "vm" {
    name = "${azurerm_resource_group.rg.name}-vm"
    computer_name = "collector"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_D4s_v4"
    admin_username = "laadmin"
    admin_password = "TFB2248hxq!!"
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 256
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2019-Datacenter"
        version = "latest"
    }
}
