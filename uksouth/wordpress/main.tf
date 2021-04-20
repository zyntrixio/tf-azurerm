resource "azurerm_resource_group" "rg" {
    name = "uksouth-${var.environment}"
    location = "uksouth"

    tags = var.tags
}

resource "azurerm_public_ip" "pip" {
    name = "${var.environment}-pip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Static"
    sku = "Standard"

    tags = var.tags
}

resource "azurerm_dns_a_record" "pip" {
    name = "wordpress.uksouth"
    zone_name = var.dns_zone.bink_sh.dns_zone_name
    resource_group_name = var.dns_zone.bink_sh.resource_group_name
    ttl = 300
    target_resource_id = azurerm_public_ip.pip.id
}

resource "azurerm_dns_caa_record" "pip" {
    name = "wordpress.uksouth"
    zone_name = var.dns_zone.bink_sh.dns_zone_name
    resource_group_name = var.dns_zone.bink_sh.resource_group_name
    ttl = 300

    record {
        flags = 0
        tag = "issue"
        value = "wordpress.uksouth.bink.sh"
    }

    record {
        flags = 0
        tag = "issuewild"
        value = ";"
    }

    record {
        flags = 0
        tag = "iodef"
        value = "mailto:devops@bink.com"
    }
}

resource "azurerm_dns_a_record" "apex_afd" {
    name = "@"
    zone_name = var.dns_zone.bink_com.dns_zone_name
    resource_group_name = var.dns_zone.bink_com.resource_group_name
    ttl = 300
    target_resource_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/frontdoor/providers/Microsoft.Network/frontdoors/bink-frontdoor"
}

resource "azurerm_dns_cname_record" "www_afd" {
    name = "www"
    zone_name = var.dns_zone.bink_com.dns_zone_name
    resource_group_name = var.dns_zone.bink_com.resource_group_name
    ttl = 300
    record = "bink-frontdoor.azurefd.net"
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["192.168.0.0/24"] # Using a common range to prevent it being added to Azure Front Door

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

    security_rule {
        name = "BlockEverything"
        description = "Default Block All Rule"
        access = "Deny"
        priority = 4096
        direction = "Inbound"
        protocol = "*"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "*"
    }
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

resource "azurerm_subnet" "subnet0" {
    name = "subnet0"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["192.168.0.0/24"]
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
}

resource "azurerm_linux_virtual_machine" "vm" {
    name = var.environment
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_B2ms"
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
