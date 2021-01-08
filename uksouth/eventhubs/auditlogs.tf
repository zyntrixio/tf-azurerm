resource "azurerm_eventhub" "auditlogs" {
    name = "auditlogs"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "auditlogswrite" {
    name = "auditlogswrite"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    eventhub_name = azurerm_eventhub.auditlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    listen = false
    send = true
    manage = false
}

resource "azurerm_eventhub_authorization_rule" "auditlogsread" {
    name = "auditlogsread"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    eventhub_name = azurerm_eventhub.auditlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    listen = true
    send = false
    manage = false
}
