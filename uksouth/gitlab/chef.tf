resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name

    default_attributes_json = jsonencode({
        "elasticsearch" : {
            "heapsize" : 8,
            "nodes" : ["elasticsearch-00", "elasticsearch-01", "elasticsearch-02"]
        }
    })
}

resource "chef_role" "role" {
    name = "gitlab"
    run_list = [
        "recipe[fury]",
        "recipe[jarvis]",
        "recipe[black_widow]",
        "recipe[nebula]"
    ]
}
