resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
    cookbook_constraints = {
        fury = ">= 1.5.1"
        rorschach = ">= 1.0.1"
        jarvis = ">= 2.1.0"
        nebula = "= 2.0.4"
    }

    default_attributes_json = jsonencode({
        "rorschach" : {
            "domain" : "tableau.uksouth.bink.sh",
            "port" : 8080
        }
    })
}

resource "chef_role" "tableau" {
    name = "tableau"
    run_list = [
        "recipe[fury]",
        "recipe[rorschach]",
        "recipe[jarvis]",
        "recipe[nebula]"
    ]
}
