terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">= 2.83.0"
            configuration_aliases = [ azurerm.core ]
        }
    }
}

resource "azurerm_resource_group" "rg" {
    name = "uksouth-tableau"
    location = "uksouth"
}

resource "azurerm_virtual_network" "vnet" {
    name = "uksouth-tableau-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [ var.ip_range ]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [ var.ip_range ]
}

resource "azurerm_virtual_network_peering" "local-to-fw" {
    name = "local-to-fw"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = var.firewall.vnet_id
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "fw-to-local" {
    provider = azurerm.core

    name = "local-to-tableau-prod"
    resource_group_name = var.firewall.resource_group_name
    virtual_network_name = var.firewall.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.vnet.id
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "local-to-environment" {
    name = "local-to-environment"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = var.environment.vnet_id
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "environment-to-local" {
    name = "local-to-tableau-prod"
    resource_group_name = var.environment.resource_group_name
    virtual_network_name = var.environment.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.vnet.id
    allow_forwarded_traffic = true
}

resource "azurerm_route_table" "rt" {
    name = "uksouth-tableau-routes"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    disable_bgp_route_propagation = true

    route {
        name = "firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = "192.168.0.4"
    }
}


resource "azurerm_network_security_group" "nsg" {
    name = "uksouth-tableau-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

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

    dynamic security_rule {
        for_each = {
            "Allow_TCP_22" = {"priority": "100", "port": "22", "source": "192.168.4.0/24"},
            "Allow_TCP_9100" = {"priority": "110", "port": "9100", "source": "10.50.0.0/16"},
            "Allow_TCP_80" = {"priority": "200", "port": "80", "source": "192.168.0.0/24"},
            "Allow_TCP_443" = {"priority": "210", "port": "443", "source": "192.168.0.0/24"},
            "Allow_TCP_5432" = {"priority": "220", "port": "5432", "source": "192.168.0.0/24"},

        }
        content {
            name = security_rule.key
            priority = security_rule.value.priority
            access = "Allow"
            protocol = "Tcp"
            direction = "Inbound"
            source_port_range = "*"
            source_address_prefix = security_rule.value.source
            destination_port_range = security_rule.value.port
            destination_address_prefix = var.ip_range
        }
    }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_network_security_group.nsg.id
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

resource "azurerm_storage_account" "i" {
    name = "binkuksouthtableau"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    cross_tenant_replication_enabled = false
    account_tier = "Standard"
    account_replication_type = "ZRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
    provider = azurerm.core
    name = azurerm_virtual_network.vnet.name
    resource_group_name = var.private_dns.resource_group
    private_dns_zone_name = var.private_dns.primary_zone
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
    provider = azurerm.core
    for_each = toset(var.private_dns.secondary_zones)
    name = azurerm_virtual_network.vnet.name
    resource_group_name = var.private_dns.resource_group
    private_dns_zone_name = each.key
    virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "pgfs" {
    name = "private.postgres.database.azure.com-to-${azurerm_resource_group.rg.name}"
    private_dns_zone_name = var.postgres_flexible_server_dns_link.name
    virtual_network_id = azurerm_virtual_network.vnet.id
    resource_group_name = var.postgres_flexible_server_dns_link.resource_group_name
}

resource "azurerm_network_interface" "nic" {
    name = "tableau-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = true

    ip_configuration {
        name = "config"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    name = "tableau"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_E16as_v5"
    admin_username = "terraform"
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    admin_ssh_key {
        username   = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadOnly"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 1024
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18_04-lts-gen2"
        version = "latest"
    }

    lifecycle { ignore_changes = [custom_data] }
}
