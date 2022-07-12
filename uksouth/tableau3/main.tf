terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">= 2.83.0"
            configuration_aliases = [ azurerm.core ]
        }
        chef = {
            source = "terrycain/chef"
        }
    }
}

resource "azurerm_resource_group" "rg" {
    name = "uksouth-tableau-sandbox"
    location = "uksouth"
}

resource "chef_environment" "env" {
    name = "${azurerm_resource_group.rg.name}"
    cookbook_constraints = {
        jarvis = ">= 2.1.0"
        fury = ">= 2.2.0"
        nebula = ">= 2.1.0"
    }
}

resource "azurerm_virtual_network" "vnet" {
    name = "uksouth-tableau-sandbox-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [ "192.168.102.0/24" ]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [ "192.168.102.0/24" ]
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

    name = "local-to-tableau-sandbox"
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
    name = "local-to-tableau-sandbox"
    resource_group_name = var.environment.resource_group_name
    virtual_network_name = var.environment.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.vnet.id
    allow_forwarded_traffic = true
}

resource "azurerm_route_table" "rt" {
    name = "uksouth-tableau-sandbox-routes"
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
    name = "uksouth-tableau-sandbox-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name = "AllowHttp"
        description = "HTTP/HTTPS Access"
        access = "Allow"
        priority = 100
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefixes = [
            "192.168.0.0/24", # Azure Firewall for Ingress
        ]
        source_port_range = "*"
        destination_address_prefix = "192.168.102.0/24"
        destination_port_ranges = [80, 443]
    }
    security_rule {
        name = "AllowPsql"
        description = "Postgres Access"
        access = "Allow"
        priority = 110
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefixes = [
            "192.168.0.0/24", # Azure Firewall for Ingress
        ]
        source_port_range = "*"
        destination_address_prefix = "192.168.102.0/24"
        destination_port_ranges = [5432]
    }
    security_rule {
        name = "AllowSSH"
        description = "Allow SSH Access from Bastion Subnet"
        access = "Allow"
        priority = 500
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefix = "192.168.4.0/24"
        source_port_range = "*"
        destination_address_prefix = "192.168.102.0/24"
        destination_port_range = "22"
    }
    security_rule {
        name = "AllowNodeExporterAccess"
        description = "Tools Prometheus -> Node Exporter"
        access = "Allow"
        priority = 510
        direction = "Inbound"
        protocol = "Tcp"
        source_address_prefix = "10.33.0.0/18"
        source_port_range = "*"
        destination_address_prefix = "192.168.102.0/24"
        destination_port_ranges = [9100]
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

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
    subnet_id = azurerm_subnet.subnet.id
    route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "pgfs" {
    name = "private.postgres.database.azure.com-to-${azurerm_resource_group.rg.name}"
    private_dns_zone_name = var.postgres_flexible_server_dns_link.name
    virtual_network_id = azurerm_virtual_network.vnet.id
    resource_group_name = var.postgres_flexible_server_dns_link.resource_group_name
}

resource "azurerm_network_interface" "nic" {
    name = "tableau-sandbox-nic"
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
    name = "tableau-sandbox"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_D8as_v4"
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
        sku = "18.04-LTS"
        version = "latest"
    }

    custom_data = base64gzip(
        templatefile(
            "${path.root}/init.tmpl",
            {
                cinc_run_list = base64encode(jsonencode(
                    { "run_list" : ["recipe[fury]", "recipe[nebula]", "recipe[jarvis]"] }
                )),
                cinc_environment = chef_environment.env.name
                cinc_data_secret = ""
            }
        )
    )

    lifecycle { ignore_changes = [custom_data] }
}
