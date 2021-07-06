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
    sku = "Standard"
}

resource "azurerm_lb" "lb" {
    name = "${azurerm_resource_group.rg.name}-lb"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "Standard"

    frontend_ip_configuration {
        name = "PublicIPAddress"
        public_ip_address_id = azurerm_public_ip.ip.id
        private_ip_address_version = "IPv4"
    }
}

resource "azurerm_lb_backend_address_pool" "linux" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "linux"
}

resource "azurerm_lb_backend_address_pool" "windows" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "windows"
}

resource "azurerm_lb_probe" "ssh" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "ssh"
    port = 22
}

resource "azurerm_lb_probe" "rdp" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "rdp"
    port = 3389
}

resource "azurerm_lb_rule" "ssh" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "ssh"
    protocol = "Tcp"
    frontend_port = 22
    backend_port = 22
    frontend_ip_configuration_name = "PublicIPAddress"
    backend_address_pool_id = azurerm_lb_backend_address_pool.linux.id
    probe_id = azurerm_lb_probe.ssh.id
}

resource "azurerm_lb_rule" "rdp" {
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    name = "rdp"
    protocol = "Tcp"
    frontend_port = 3389
    backend_port = 3389
    frontend_ip_configuration_name = "PublicIPAddress"
    backend_address_pool_id = azurerm_lb_backend_address_pool.windows.id
    probe_id = azurerm_lb_probe.rdp.id
}

resource "azurerm_dns_a_record" "a" {
    name = "redscan.uksouth"
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

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    log {
        category = "NetworkSecurityGroupEvent"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "NetworkSecurityGroupRuleCounter"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
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

resource "azurerm_network_interface" "windows" {
    name = "${azurerm_resource_group.rg.name}-windows"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = true

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "windows" {
    network_interface_id = azurerm_network_interface.windows.id
    ip_configuration_name = "internal"
    backend_address_pool_id = azurerm_lb_backend_address_pool.windows.id
}

resource "azurerm_network_interface" "linux" {
    name = "${azurerm_resource_group.rg.name}-linux"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = true

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "linux" {
    network_interface_id = azurerm_network_interface.linux.id
    ip_configuration_name = "internal"
    backend_address_pool_id = azurerm_lb_backend_address_pool.linux.id
}

resource "azurerm_network_security_rule" "ssh" {
    name = "Secure Shell"
    priority = 200
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefixes = var.secure_origins
    # destination_address_prefixes = [azurerm_public_ip.ip.ip_address]
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "rdp" {
    name = "Remote Desktop"
    priority = 210
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefixes = var.secure_origins
    # destination_address_prefixes = [azurerm_public_ip.ip.ip_address]
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_linux_virtual_machine" "linux" {
    name = "${azurerm_resource_group.rg.name}-linux"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_D4s_v4"
    admin_username = "laadmin"
    network_interface_ids = [
        azurerm_network_interface.linux.id,
    ]

    admin_ssh_key {
        username   = "laadmin"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
        disk_size_gb = 256
    }
    source_image_reference {
        publisher = "RedHat"
        offer     = "RHEL"
        sku       = "8-LVM"
        version   = "latest"
    }
}

resource "azurerm_windows_virtual_machine" "windows" {
    name = "${azurerm_resource_group.rg.name}-windows"
    computer_name = "windows"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_D4s_v4"
    admin_username = "laadmin"
    admin_password = "TFB2248hxq!!"
    network_interface_ids = [
        azurerm_network_interface.windows.id,
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
