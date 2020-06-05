resource "azurerm_virtual_network" "vnet" {
    name = "firewall-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["192.168.0.0/24"]

    tags = var.tags
}

resource "azurerm_subnet" "subnet" {
    name = "AzureFirewallSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefix = "192.168.0.0/24"
}

resource "azurerm_public_ip_prefix" "prefix" {
    name = "firewall-pip-prefix"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    prefix_length = 28

    tags = var.tags
}

resource "azurerm_public_ip" "pips" {
    count = 16
    name = format("firewall-pip-prefix-%02d", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
    sku = "Standard"
    idle_timeout_in_minutes = 5
    public_ip_prefix_id = azurerm_public_ip_prefix.prefix.id

    tags = var.tags
}

# TODO: Cleanup the below IP Config Blocks by using Terraform 0.12 Syntax
resource "azurerm_firewall" "firewall" {
    name = "firewall"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "ipconfig0"
        subnet_id = azurerm_subnet.subnet.id
        public_ip_address_id = azurerm_public_ip.pips.0.id
    }
    ip_configuration {
        name = "ipconfig1"
        public_ip_address_id = azurerm_public_ip.pips.1.id
    }
    ip_configuration {
        name = "ipconfig2"
        public_ip_address_id = azurerm_public_ip.pips.2.id
    }
    ip_configuration {
        name = "ipconfig3"
        public_ip_address_id = azurerm_public_ip.pips.3.id
    }
    ip_configuration {
        name = "ipconfig4"
        public_ip_address_id = azurerm_public_ip.pips.4.id
    }
    ip_configuration {
        name = "ipconfig5"
        public_ip_address_id = azurerm_public_ip.pips.5.id
    }
    ip_configuration {
        name = "ipconfig6"
        public_ip_address_id = azurerm_public_ip.pips.6.id
    }
    ip_configuration {
        name = "ipconfig7"
        public_ip_address_id = azurerm_public_ip.pips.7.id
    }
    ip_configuration {
        name = "ipconfig8"
        public_ip_address_id = azurerm_public_ip.pips.8.id
    }
    ip_configuration {
        name = "ipconfig9"
        public_ip_address_id = azurerm_public_ip.pips.9.id
    }
    ip_configuration {
        name = "ipconfig10"
        public_ip_address_id = azurerm_public_ip.pips.10.id
    }
    ip_configuration {
        name = "ipconfig11"
        public_ip_address_id = azurerm_public_ip.pips.11.id
    }
    ip_configuration {
        name = "ipconfig12"
        public_ip_address_id = azurerm_public_ip.pips.12.id
    }
    ip_configuration {
        name = "ipconfig13"
        public_ip_address_id = azurerm_public_ip.pips.13.id
    }
    ip_configuration {
        name = "ipconfig14"
        public_ip_address_id = azurerm_public_ip.pips.14.id
    }
    ip_configuration {
        name = "ipconfig15"
        public_ip_address_id = azurerm_public_ip.pips.15.id
    }

    tags = var.tags
}

resource "azurerm_virtual_network_peering" "vault" {
    name = "local-to-vault"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-vault/providers/Microsoft.Network/virtualNetworks/vault-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "bastion" {
    name = "local-to-bastion"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-bastion/providers/Microsoft.Network/virtualNetworks/bastion-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "prod" {
    name = "local-to-prod"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-prod/providers/Microsoft.Network/virtualNetworks/prod-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "staging" {
    name = "local-to-staging"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-staging/providers/Microsoft.Network/virtualNetworks/staging-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "dev" {
    name = "local-to-dev"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-dev/providers/Microsoft.Network/virtualNetworks/dev-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "sandbox" {
    name = "local-to-sandbox"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-sandbox/providers/Microsoft.Network/virtualNetworks/sandbox-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "chef" {
    name = "local-to-chef"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-chef/providers/Microsoft.Network/virtualNetworks/chef-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "monitoring" {
    name = "local-to-monitoring"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-monitoring/providers/Microsoft.Network/virtualNetworks/monitoring-vnet"
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "sentry" {
    name = "local-to-sentry"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = var.sentry_vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "tableau" {
    name = "local-to-tableau"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = var.tableau_vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "tools" {
    name = "local-to-tools"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    remote_virtual_network_id = var.tools_vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_private_dns_zone" "uksouth" {
    name = "uksouth.bink.sh"
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "bastion" {
    name = "bastion"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-bastion/providers/Microsoft.Network/virtualNetworks/bastion-vnet"
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "prod" {
    name = "prod"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-prod/providers/Microsoft.Network/virtualNetworks/prod-vnet"
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "staging" {
    name = "staging"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-staging/providers/Microsoft.Network/virtualNetworks/staging-vnet"
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "dev" {
    name = "dev"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-dev/providers/Microsoft.Network/virtualNetworks/dev-vnet"
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "sandbox" {
    name = "sandbox"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-sandbox/providers/Microsoft.Network/virtualNetworks/sandbox-vnet"
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "chef" {
    name = "chef"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-chef/providers/Microsoft.Network/virtualNetworks/chef-vnet"
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "monitoring" {
    name = "monitoring"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-monitoring/providers/Microsoft.Network/virtualNetworks/monitoring-vnet"
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "sentry" {
    name = "sentry"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = var.sentry_vnet_id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "tableau" {
    name = "tableau"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = var.tableau_vnet_id
    registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "tools" {
    name = "tools"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.uksouth.name
    virtual_network_id = var.tools_vnet_id
    registration_enabled = true
}
