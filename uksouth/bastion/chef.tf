resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
    cookbook_constraints = {
        nebula = "= 2.1.0"
    }

    default_attributes_json = jsonencode({
        azure_eventhub_logging = {
            oslogs_endpoint = var.eventhub_logs.oslogs.endpoint
            oslogs_connection_string = var.eventhub_logs.oslogs.connection_string_write
            auditlogs_endpoint = var.eventhub_logs.auditlogs.endpoint
            auditlogs_connection_string = var.eventhub_logs.auditlogs.connection_string_write
        }
    })
}

resource "chef_role" "role" {
    name = "bastion"
    run_list = [
        "recipe[fury]",
        "recipe[jarvis]",
        "recipe[nebula]"
    ]
}
