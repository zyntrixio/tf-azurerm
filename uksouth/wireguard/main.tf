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

output "public_ip" {
    value = azurerm_public_ip.pip.ip_address
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.environment}-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.ip_range]

    tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
    name = "${var.environment}-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

    security_rule {
        name = "AllowWireguard"
        description = "Wireguard Access"
        access = "Allow"
        priority = 100
        direction = "Inbound"
        protocol = "UDP"
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_ranges = [51820]
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
        name = "AllowPrometheus"
        description = "Allow Prometheus to hit exporters"
        access = "Allow"
        priority = 510
        direction = "Inbound"
        protocol = "TCP"
        source_address_prefixes = var.prometheus_origin
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_ranges = [9100, 9586]
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
    log_analytics_workspace_id = var.loganalytics_id
    log_analytics_destination_type = "AzureDiagnostics"

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
    address_prefixes = [var.ip_range]
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    subnet_id = azurerm_subnet.subnet0.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "wireguard" {
    name = "${var.environment}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = true

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet0.id
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.ip_range, 4)
        public_ip_address_id = azurerm_public_ip.pip.id
    }
}

resource "azurerm_linux_virtual_machine" "wireguard" {
    name = "wireguard"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_D4s_v4"
    admin_username = "terraform"
    tags = var.tags
    network_interface_ids = [
        azurerm_network_interface.wireguard.id
    ]

    admin_ssh_key {
        username = "terraform"
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

    custom_data = base64gzip(
        templatefile(
            "${path.root}/init.tmpl",
            {
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[${chef_role.role.name}]"] })),
                cinc_environment = chef_environment.env.name
                cinc_data_secret = ""
            }
        )
    )

    lifecycle {
        ignore_changes = [custom_data]
    }
}
