resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
    cookbook_constraints = {
        fury = ">= 1.5.0"
        rorschach = ">= 1.0.1"
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
        #        "recipe[rorschach]"
    ]
}
