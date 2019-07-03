resource "azurerm_virtual_network" "vnet" {
    name = "${azurerm_resource_group.rg.name}-vnet"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    address_space = ["192.168.0.0/24"]

    tags = {
        environment = "production"
    }
}

resource "azurerm_subnet" "subnet" {
    name = "AzureFirewallSubnet"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "192.168.0.0/24"
}

resource "azurerm_public_ip" "pip" {
    name = "${azurerm_resource_group.rg.name}-pip"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_firewall" "firewall" {
    name = "${azurerm_resource_group.rg.name}"
    location = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "ipconfig"
        subnet_id = "${azurerm_subnet.subnet.id}"
        public_ip_address_id = "${azurerm_public_ip.pip.id}"
    }
}

resource "azurerm_virtual_network_peering" "vault" {
    name = "local-to-vault"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-vault/providers/Microsoft.Network/virtualNetworks/uksouth-vault-vnet"
    allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "prod" {
    name = "local-to-prod"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-prod/providers/Microsoft.Network/virtualNetworks/uksouth-prod-vnet"
    allow_virtual_network_access = true
}
