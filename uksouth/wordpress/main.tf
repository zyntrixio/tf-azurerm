resource "azurerm_resource_group" "rg" {
    name = "uksouth-${var.environment}"
    location = "uksouth"

    tags = var.tags
}

resource "azurerm_public_ip" "pip" {
    name = "${var.environment}-pip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    ip_version = "IPv4"
    allocation_method = "Static"
    sku = "Standard"

    tags = var.tags
}

resource "azurerm_public_ip" "pip6" {
    name = "${var.environment}-pip6"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    ip_version = "IPv6"
    allocation_method = "Static"
    sku = "Standard"

    tags = var.tags
}

resource "azurerm_dns_a_record" "apex" {
    name = "@"
    zone_name = var.dns_zone.bink_com.dns_zone_name
    resource_group_name = var.dns_zone.bink_com.resource_group_name
    ttl = 300
    records = [azurerm_public_ip.pip.ip_address]
}

resource "azurerm_dns_aaaa_record" "apex" {
    name = "@"
    zone_name = var.dns_zone.bink_com.dns_zone_name
    resource_group_name = var.dns_zone.bink_com.resource_group_name
    ttl = 300
    records = [azurerm_public_ip.pip6.ip_address]
}

resource "azurerm_dns_a_record" "www" {
    name = "www"
    zone_name = var.dns_zone.bink_com.dns_zone_name
    resource_group_name = var.dns_zone.bink_com.resource_group_name
    ttl = 300
    records = [azurerm_public_ip.pip.ip_address]
}

resource "azurerm_dns_aaaa_record" "www" {
    name = "www"
    zone_name = var.dns_zone.bink_com.dns_zone_name
    resource_group_name = var.dns_zone.bink_com.resource_group_name
    ttl = 300
    records = [azurerm_public_ip.pip6.ip_address]
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["192.168.0.0/24", "ace:cab:deca:deed::/64"]

    tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
    name = "${var.environment}-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

    security_rule {
        name = "AllowHTTP"
        description = "Allow HTTP Access"
        access = "Allow"
        priority = 100
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "80"
    }

    security_rule {
        name = "AllowHTTPS"
        description = "Allow HTTPS Access"
        access = "Allow"
        priority = 200
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "443"
    }

    security_rule {
        name = "AllowSSH"
        description = "Allow SSH Access"
        access = "Allow"
        priority = 500
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefixes = var.secure_origins
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "22"
    }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.nsg.id
    eventhub_name = "azurensg"
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    log_analytics_workspace_id = var.loganalytics_id

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

resource "azurerm_subnet" "subnet0" {
    name = "subnet0"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["192.168.0.0/24", "ace:cab:deca:deed::/64"]
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    subnet_id = azurerm_subnet.subnet0.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
    name = "${var.environment}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = false

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet0.id
        private_ip_address_allocation = "Static"
        private_ip_address = "192.168.0.4"
        public_ip_address_id = azurerm_public_ip.pip.id
    }

    ip_configuration {
        name = "IPv6"
        subnet_id = azurerm_subnet.subnet0.id
        private_ip_address_allocation = "Static"
        private_ip_address = "ace:cab:deca:deed::4"
        private_ip_address_version = "IPv6"
        public_ip_address_id = azurerm_public_ip.pip6.id
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    name = var.environment
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_B2s"
    admin_username = "terraform"
    tags = var.tags
    network_interface_ids = [
        azurerm_network_interface.nic.id
    ]

    admin_ssh_key {
        username = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadOnly"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 64
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-focal"
        sku = "20_04-lts"
        version = "latest"
    }
}
