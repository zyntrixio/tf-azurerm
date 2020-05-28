resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
    cookbook_constraints = {
        fury = ">= 1.5.0"
    }

    default_attributes_json = jsonencode({
        "acr" : {
            "registry" : azurerm_container_registry.acr.login_server,
            "username" : azurerm_container_registry.acr.admin_username,
            "password" : azurerm_container_registry.acr.admin_password
        }
    })
}
