resource "azurerm_virtual_network" "vnet" {
  name = "${var.environment}-vnet"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["192.168.6.0/24"]

  tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
  count = length(var.subnet_address_prefixes)
  name = format("${var.environment}-subnet-%02d-nsg", count.index + 1)
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  count = length(var.subnet_address_prefixes)
  name = format("subnet-%02d", count.index + 1)
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix = element(var.subnet_address_prefixes, count.index)
}

#resource "azurerm_network_watcher_flow_log" "flow_logs" {
#  count = length(var.subnet_address_prefixes)
#  network_watcher_name = "NetworkWatcher_ukwest"
#  resource_group_name = "NetworkWatcherRG"

#  network_security_group_id = element(azurerm_network_security_group.nsg.*.id, count.index)
#  storage_account_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/stega/providers/Microsoft.Storage/storageAccounts/binkstegansgflowlogs"
#  enabled = false
#  version = 2

#  retention_policy {
#    enabled = true
#    days    = 3
#  }
#}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  count = length(var.subnet_address_prefixes)
  subnet_id = element(azurerm_subnet.subnet.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.nsg.*.id, count.index)
}

resource "azurerm_public_ip" "pip" {
  name = "${var.environment}-pip"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
  allocation_method = "Static"

  tags = var.tags
}

resource "azurerm_lb" "plb" {
  name = "${var.environment}-plb"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name = azurerm_public_ip.pip.name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = var.tags 
}

resource "azurerm_lb" "lb" {
  name = "${var.environment}-lb"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name = "subnet-01"
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.subnet_address_prefixes[0], 4)
    subnet_id = azurerm_subnet.subnet.0.id
  }
  frontend_ip_configuration {
    name = "subnet-02"
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.subnet_address_prefixes[1], 4)
    subnet_id = azurerm_subnet.subnet.1.id
  }
  frontend_ip_configuration {
    name = "subnet-03"
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.subnet_address_prefixes[2], 4)
    subnet_id = azurerm_subnet.subnet.2.id
  }
  frontend_ip_configuration {
    name = "subnet-04"
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.subnet_address_prefixes[3], 4)
    subnet_id = azurerm_subnet.subnet.3.id
  }
  frontend_ip_configuration {
    name = "subnet-05"
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.subnet_address_prefixes[4], 4)
    subnet_id = azurerm_subnet.subnet.4.id
  }
  frontend_ip_configuration {
    name = "subnet-06"
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(var.subnet_address_prefixes[5], 4)
    subnet_id = azurerm_subnet.subnet.5.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "ppools" {
  count = length(var.subnet_address_prefixes)
  name = format("subnet-%02d", count.index + 1)
  loadbalancer_id = azurerm_lb.plb.id
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_lb_backend_address_pool" "pools" {
  count = length(var.subnet_address_prefixes)
  name = format("subnet-%02d", count.index + 1)
  loadbalancer_id = azurerm_lb.lb.id
  resource_group_name = azurerm_resource_group.rg.name
}
