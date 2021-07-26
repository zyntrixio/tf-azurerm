module "uksouth_preprod_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=2.3.0"
    providers = {
        azurerm = azurerm.uk_preprod
    }
    resource_group_name = "uksouth-preprod"
    location = "uksouth"
    tags = {
        "Environment" = "Pre-Production",
    }

    postgres_iam = {
        ChrisSterritt = {
            object_id = local.aad_user.chris_sterritt,
            role = "Contributor",
        }
    }

    keyvault_iam = {
        Backend = {
            object_id = local.aad_group.backend,
            role = "Reader",
        },
    }

    storage_iam = {
        Backend = {
            storage_id = "common",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
    }

    keyvault_users = {
        Backend = local.aad_group.backend,
    }

    # postgres_config = {
    #     common = {
    #         name = "bink-uksouth-preprod-common",
    #         sku_name = "GP_Gen5_2",
    #         storage_gb = 500,
    #         public_access = true,
    #         databases = ["atlas", "europa", "pontus", "thanatos", "zagreus"]
    #     },
    #     hermes = {
    #         name = "bink-uksouth-preprod-hermes",
    #         sku_name = "GP_Gen5_2",
    #         storage_gb = 500,
    #         public_access = true,
    #         databases = ["hermes"]
    #     },
    #     hades = {
    #         name = "bink-uksouth-preprod-hades",
    #         sku_name = "GP_Gen5_2",
    #         storage_gb = 500,
    #         public_access = true,
    #         databases = ["hades"]
    #     },
    #     harmonia = {
    #         name = "bink-uksouth-preprod-harmonia",
    #         sku_name = "GP_Gen5_4",
    #         storage_gb = 500,
    #         public_access = true,
    #         databases = ["harmonia"]
    #     },
    #     polaris = {
    #         name = "bink-uksouth-preprod-polaris",
    #         sku_name = "GP_Gen5_4",
    #         storage_gb = 500,
    #         public_access = true,
    #         databases = ["polaris"]
    #     },
    # }
    # redis_config = {
    #     common = {
    #         name = "bink-uksouth-preprod-common",
    #     },
    # }
    # redis_patch_schedule = {
    #     day_of_week = "Wednesday"
    #     start_hour_utc = 1
    # }
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    storage_config = {
        common = {
            name = "binkuksouthpreprod",
            account_replication_type = "ZRS",
        },
    }
    storage_management_policy_config = {
        common = [
            {
                name = "backupshourly",
                enabled = true,
                prefix_match = ["backups/hourly"],
                delete_after_days = 30
            },
            {
                name = "backupsweekly",
                enabled = true,
                prefix_match = ["backups/weekly"],
                delete_after_days = 90
            },
            {
                name = "backupsyearly",
                enabled = true,
                prefix_match = ["backups/yearly"],
                delete_after_days = 1095
            }
        ]
    }
    cert_manager_zone_id = module.uksouth-dns.bink-sh[2]

    managed_identities = local.managed_identities
}

# module "uksouth_preprod_cluster_0" {
#     source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=2.4.4"
#     providers = {
#         azurerm = azurerm.uk_preprod
#         azurerm.core = azurerm
#     }

#     resource_group_name = "uksouth-preprod-k0"
#     cluster_name = "preprod0"
#     location = "uksouth"
#     vnet_cidr = "10.69.0.0/16"
#     eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

#     bifrost_version = "4.8.5"
#     ubuntu_version = "20.04"
#     controller_vm_size = "Standard_D2as_v4"
#     worker_vm_size = "Standard_D4s_v4"
#     worker_scaleset_size = 5
#     use_scaleset = true
#     max_pods_per_host = 100

#     prometheus_subnet = "10.33.0.0/18"

#     flux_environment = "uksouth-preprod"

#     common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
#     common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity

#     # DNS zones
#     private_dns = module.uksouth-dns.private_dns
#     public_dns = module.uksouth-dns.public_dns

#     # Peers    
#     peers = {
#         firewall = {
#             vnet_id = module.uksouth-firewall.vnet_id
#             vnet_name = module.uksouth-firewall.vnet_name
#             resource_group_name = module.uksouth-firewall.resource_group_name
#         }
#         elasticsearch = {
#             vnet_id = module.uksouth-elasticsearch.vnet_id
#             vnet_name = module.uksouth-elasticsearch.vnet_name
#             resource_group_name = module.uksouth-elasticsearch.resource_group_name
#         }
#     }

#     firewall = {
#         firewall_name = module.uksouth-firewall.firewall_name
#         resource_group_name = module.uksouth-firewall.resource_group_name
#         ingress_priority = 800
#         rule_priority = 800
#         public_ip = module.uksouth-firewall.public_ips.15.ip_address
#         secure_origins = local.secure_origins
#         developer_ips = local.developer_ips
#         ingress_source = "*"
#         ingress_http = 8000
#         ingress_https = 4000
#         ingress_controller = 6000
#     }

#     postgres_servers = module.uksouth_preprod_environment.postgres_servers

#     tags = {
#         "Environment" = "Pre-Production",
#     }
# }
