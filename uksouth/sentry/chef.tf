# resource "chef_environment" "env" {
#     name = azurerm_resource_group.rg.name

#     default_attributes_json = jsonencode({
#         "rorschach": {
#             "domain": "sentry.uksouth.bink.sh",
#             "port": 9000,
#             "nginx": {
#                 "client_max_body_size": 1024
#             }
#         }
#     })
# }

# resource "chef_role" "sentry" {
#     name = "sentry"
#     run_list = [
#         "recipe[fury]",
#         "recipe[jarvis]",
#         "recipe[gamora]",
#         "recipe[rorschach]"
#     ]
# }


