resource "azurerm_eventhub" "oslogs" {
    name = "oslogs"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "oslogswrite" {
    name = "oslogswrite"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    eventhub_name = azurerm_eventhub.oslogs.name
    resource_group_name = azurerm_resource_group.rg.name
    listen = false
    send = true
    manage = false
}

resource "azurerm_eventhub_authorization_rule" "oslogsread" {
    name = "oslogsread"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    eventhub_name = azurerm_eventhub.oslogs.name
    resource_group_name = azurerm_resource_group.rg.name
    listen = true
    send = false
    manage = false
}
