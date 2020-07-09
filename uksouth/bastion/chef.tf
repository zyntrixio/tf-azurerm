resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
    cookbook_constraints = {
        nebula = "= 2.0.1"
    }
}

resource "chef_role" "role" {
    name = "bastion"
    run_list = [
        "recipe[fury]",
        "recipe[jarvis]",
        "recipe[nebula]"
    ]
}
