resource "azurerm_lb_rule" "lb" {
    count = length(var.lb_port)
    resource_group_name = var.resource_group_name
    loadbalancer_id = var.loadbalancer_id
    name = element(keys(var.lb_port), count.index)
    protocol = element(var.lb_port[element(keys(var.lb_port), count.index)], 1)
    frontend_port = element(var.lb_port[element(keys(var.lb_port), count.index)], 0)
    backend_port = element(var.lb_port[element(keys(var.lb_port), count.index)], 2)
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    enable_floating_ip = false
    backend_address_pool_id = var.backend_id
    idle_timeout_in_minutes = 5
}
