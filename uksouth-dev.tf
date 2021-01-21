module "uksouth_dev_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=1.4.3"
    providers = {
        azurerm = azurerm.uk_dev
    }
    resource_group_name = "uksouth-dev"
    location = "uksouth"
    tags = {
        "Environment" = "Dev",
    }

    resource_group_iam = {
        Backend = {
            object_id = "219194f6-b186-4146-9be7-34b731e19001",
            role = "Contributor",
        },
        QA = {
            object_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d",
            role = "Contributor",
        },
    }

    keyvault_users = {
        Backend = { object_id = "219194f6-b186-4146-9be7-34b731e19001" },
        QA = { object_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d" },
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-dev-common",
            sku_name = "GP_Gen5_4",
            storage_gb = 500,
            databases = ["*"]
        },
    }
    redis_config = {
        common = {
            name = "bink-uksouth-dev-common",
        },
    }
    redis_patch_schedule = {
        day_of_week = "Monday"
        start_hour_utc = 1
    }
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    storage_config = {
        common = {
            name = "binkuksouthdev",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
}

module "uksouth_dev_cluster_0" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=1.5.0"
    providers = {
        azurerm = azurerm.uk_dev
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-dev-k0"
    cluster_name = "dev0"
    location = "uksouth"
    vnet_cidr = "10.99.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    bifrost_version = "4.6.1"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2s_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_count = 5

    prometheus_subnet = "10.33.0.0/18"

    # Gitops repo, Managed identity for syncing common secrets
    gitops_repo = "git@git.bink.com:GitOps/uksouth-dev.git"
    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity

    # DNS zones
    private_dns = module.uksouth-dns.private_dns
    public_dns = module.uksouth-dns.public_dns

    # Peers    
    peers = {
        firewall = {
            vnet_id = module.uksouth-firewall.vnet_id
            vnet_name = module.uksouth-firewall.vnet_name
            resource_group_name = module.uksouth-firewall.resource_group_name
        }
        elasticsearch = {
            vnet_id = module.uksouth-elasticsearch.vnet_id
            vnet_name = module.uksouth-elasticsearch.vnet_name
            resource_group_name = module.uksouth-elasticsearch.resource_group_name
        }
    }

    firewall = {
        firewall_name = module.uksouth-firewall.firewall_name
        resource_group_name = module.uksouth-firewall.resource_group_name
        ingress_priority = 500
        rule_priority = 500
        public_ip = module.uksouth-firewall.public_ips.2.ip_address
        secure_origins = local.secure_origins
        developer_ips = local.developer_ips
        ingress_source = "*"
        ingress_http = 8050
        ingress_https = 4050
        ingress_controller = 6050
    }

    postgres_servers = module.uksouth_dev_environment.postgres_servers

    tags = {
        "Environment" = "Development",
    }
}

# module "dwh" {
#     source = "./dwh"
#     providers = {
#         azurerm = azurerm.uk_dev
#     }

#     resource_group_name = "uksouth-dev-dwh"
#     location = "uksouth"
#     environment = "dev"
#     tags = {
#         "Environment" = "Dev",
#     }

#     resource_group_iam = {
#         Architecture = {
#             object_id = "fb26c586-72a5-4fbc-b2b0-e1c28ef4fce1",
#             role = "Reader"
#         }
#         Backend = {
#             object_id = "219194f6-b186-4146-9be7-34b731e19001",
#             role = "Reader",
#         }
#     }
# }
