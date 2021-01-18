resource "chef_environment" "env" {
    name = var.resource_group_name
    cookbook_constraints = {
        manhattan = "= 2.0.3"
        fury = ">= 1.6.1"
        nebula = ">= 2.2.0"
        jarvis = ">= 2.1.0"
    }

    default_attributes_json = jsonencode({
        "elasticsearch" : {
            "heapsize" : 8,
            "nodes" : ["elasticsearch-00", "elasticsearch-01", "elasticsearch-02"]
        },
    })
}

resource "chef_role" "role" {
    name = "elasticsearch"
    run_list = [
        "recipe[fury]",
        "recipe[jarvis]",
        "recipe[nebula]",
        "recipe[black_widow]",
        "recipe[manhattan]",
    ]
}
