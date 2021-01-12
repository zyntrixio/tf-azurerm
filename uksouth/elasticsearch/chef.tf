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
        "azure_eventhub_logging" = {
            oslogs_endpoint = var.eventhub_logs.oslogs.endpoint
            oslogs_connection_string = var.eventhub_logs.oslogs.connection_string_write
            auditlogs_endpoint = var.eventhub_logs.auditlogs.endpoint
            auditlogs_connection_string = var.eventhub_logs.auditlogs.connection_string_write
        }
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
