resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name

    default_attributes_json = jsonencode(var.config)
}
