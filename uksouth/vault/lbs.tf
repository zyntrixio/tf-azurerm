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

  tags = {
    environment = "production"
  }
}

resource "azurerm_lb_backend_address_pool" "pools" {
  count = length(var.subnet_address_prefixes)
  name = format("subnet-%02d", count.index + 1)
  loadbalancer_id = azurerm_lb.lb.id
  resource_group_name = azurerm_resource_group.rg.name
}
