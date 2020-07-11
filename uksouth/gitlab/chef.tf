resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
}

resource "chef_role" "role" {
    name = "gitlab"
    run_list = [
        "recipe[fury]",
        "recipe[jarvis]",
        "recipe[nebula]"
    ]
}
