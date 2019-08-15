resource "azurerm_virtual_network" "vnet" {
  name = "firewall-vnet"
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
  count = 1
  name = "${format("firewall-pip-%02d", count.index + 1)}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method = "Static"
  sku = "Standard"
  idle_timeout_in_minutes = 5
}

resource "azurerm_firewall" "firewall" {
  name = "firewall"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name = "ipconfig"
    subnet_id = "${azurerm_subnet.subnet.id}"
    public_ip_address_id = "${azurerm_public_ip.pip.0.id}"
  }
}

resource "azurerm_virtual_network_peering" "vault" {
  name = "local-to-vault"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-vault/providers/Microsoft.Network/virtualNetworks/vault-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "bastion" {
  name = "local-to-bastion"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-bastion/providers/Microsoft.Network/virtualNetworks/bastion-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "prod" {
  name = "local-to-prod"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-prod/providers/Microsoft.Network/virtualNetworks/prod-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "staging" {
  name = "local-to-staging"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-staging/providers/Microsoft.Network/virtualNetworks/staging-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "dev" {
  name = "local-to-dev"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-dev/providers/Microsoft.Network/virtualNetworks/dev-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "sanorth-dev" {
  name = "local-to-sanorth-dev"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/sanorth-dev/providers/Microsoft.Network/virtualNetworks/dev-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "chef" {
  name = "local-to-chef"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-chef/providers/Microsoft.Network/virtualNetworks/chef-vnet"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}
