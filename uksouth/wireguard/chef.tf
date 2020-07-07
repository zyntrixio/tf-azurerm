resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
    cookbook_constraints = {
        fury = ">= 1.5.1",
        jarvis = ">= 2.1.0"
    }
}

resource "chef_role" "wireguard" {
    name = "wireguard"
    run_list = [
        "recipe[fury]",
        "recipe[jarvis]"
    ]
}
