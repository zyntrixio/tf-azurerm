resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
    cookbook_constraints = {
        rorschach = ">= 1.0.1"
        jarvis = ">= 2.1.0"
        fury = ">= 1.6.1"
        nebula = "= 2.1.0"
    }

    default_attributes_json = jsonencode({
        "rorschach" : {
            "domain" : "tableau.uksouth.bink.sh",
            "port" : 8080,
            "nginx" : {
                "proxy_read_timeout" : 600,
                "proxy_send_timeout" : 600,
                "client_max_body_size" : 500,
            }
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
