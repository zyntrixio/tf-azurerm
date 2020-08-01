output "passwords" {
    value = {
        postgres = {
            for i in azurerm_postgresql_server.pg :
            i.name => i.administrator_login_password
        },
        redis = {
            for i in data.azurerm_redis_cache.redis :
            i.name => i.primary_access_key
        },
        storage = {
            for i in azurerm_storage_account.storage :
            i.name => i.primary_access_key
        },
    }
}

output "managedidentites" {
    value = {
        infra_sync = {
            client_id = azurerm_user_assigned_identity.infra_sync.client_id
            resource_id = azurerm_user_assigned_identity.infra_sync.id
            keyvault_url = azurerm_key_vault.infra.vault_uri
        }
        fakicorp = {
            client_id = azurerm_user_assigned_identity.fakicorp.client_id
            resource_id = azurerm_user_assigned_identity.fakicorp.id
            keyvault_url = azurerm_key_vault.common.vault_uri
        }
        test = [for s in azurerm_postgresql_server.pg : {test = s.name}]
    }
}

# output "postgres_passwords" {
#     value = {
#         for i in azurerm_postgresql_server.pg:
#         i.name => i.administrator_login_password
#     }
#     sensitive = false
# }


# output "instance_private_ip_addresses" {
#   # Result is a map from instance id to private IP address, such as:
#   #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
#   value = {
#     for instance in aws_instance.example:
#     instance.id => instance.private_ip
#   }
# }
