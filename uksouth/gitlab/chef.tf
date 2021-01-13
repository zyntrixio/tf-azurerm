resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name

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
    name = "gitlab"
    run_list = [
        "recipe[fury]",
        "recipe[jarvis]",
        "recipe[black_widow]",
        "recipe[nebula]"
    ]
}
