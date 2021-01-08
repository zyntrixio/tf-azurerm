# output "uksouth-bink-host" {
#     value = [azurerm_resource_group.rg.name, azurerm_private_dns_zone.uksouth-bink-host.name]
# }

# output "private_dns" {
#     value = {
#         "uksouth_sh" = {
#             resource_group_name = azurerm_resource_group.rg.name
#             private_dns_zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
#             should_register = false
#         }
#         "uksouth_host" = {
#             resource_group_name = azurerm_resource_group.rg.name
#             private_dns_zone_name = azurerm_private_dns_zone.uksouth-bink-host.name
#             should_register = true
#         }
#     }
# }

output "eventhubs" {
    value = {
        "oslogs" = {
            endpoint = "${azurerm_eventhub.oslogs.namespace_name}.servicebus.windows.net"
            connection_string_write = azurerm_eventhub_authorization_rule.oslogswrite.primary_connection_string
            connection_string_read = azurerm_eventhub_authorization_rule.oslogsread.primary_connection_string
        }
        "auditlogs" = {
            endpoint = "${azurerm_eventhub.auditlogs.namespace_name}.servicebus.windows.net"
            connection_string_write = azurerm_eventhub_authorization_rule.auditlogswrite.primary_connection_string
            connection_string_read = azurerm_eventhub_authorization_rule.auditlogsread.primary_connection_string
        }
    }
}
