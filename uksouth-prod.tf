module "uksouth_prod_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=2.2.2"
    providers = {
        azurerm = azurerm.uk_production
    }
    resource_group_name = "uksouth-prod"
    location = "uksouth"
    tags = {
        "Environment" = "Production",
    }

    postgres_iam = {
        ChrisSterritt = {
            object_id = local.aad_user.chris_sterritt,
            role = "Reader",
        }
    }

    keyvault_iam = {
        MickLatham = {
            object_id = local.aad_user.mick_latham,
            role = "Reader",
        },
        chris_latham = {
            object_id = local.aad_user.chris_latham,
            role = "Reader",
        },
        christian_prior = {
            object_id = local.aad_user.christian_prior,
            role = "Reader",
        },
    }

    storage_iam = {
        mick_latham = {
            storage_id = "common",
            object_id = local.aad_user.mick_latham,
            role = "Contributor",
        },
        chris_latham = {
            storage_id = "common",
            object_id = local.aad_user.chris_latham,
            role = "Contributor",
        },
        christian_prior = {
            storage_id = "common",
            object_id = local.aad_user.christian_prior,
            role = "Contributor",
        },
    }

    redis_iam = {
        chris_latham = {
            object_id = local.aad_user.chris_latham,
            role = "Reader",
        }
    }

    keyvault_users = {
        mick_latham = local.aad_user.mick_latham,
        chris_latham = local.aad_user.chris_latham,
        christian_prior = local.aad_user.christian_prior,
    }

    infra_keyvault_users = {
        AzureSynapse = { object_id = module.uksouth_prod_datawarehouse.synapse_identity.principal_id, permissions = ["get"] }
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-prod-common",
            sku_name = "GP_Gen5_2",
            storage_gb = 500,
            public_access = true,
            databases = ["atlas", "europa", "pontus", "thanatos", "zagreus"]
        },
        hermes = {
            name = "bink-uksouth-prod-hermes",
            sku_name = "GP_Gen5_8",
            storage_gb = 500,
            public_access = true,
            databases = ["hermes"]
        },
        hades = {
            name = "bink-uksouth-prod-hades",
            sku_name = "GP_Gen5_4",
            storage_gb = 500,
            public_access = true,
            databases = ["hades"]
        },
        harmonia = {
            name = "bink-uksouth-prod-harmonia",
            sku_name = "GP_Gen5_4",
            storage_gb = 500,
            public_access = true,
            databases = ["harmonia"]
        },
    }
    redis_config = {
        common = {
            name = "bink-uksouth-prod-common",
            family = "P",
            sku_name = "Premium",
        },
        harmonia = {
            name = "bink-uksouth-prod-harmonia",
            family = "P",
            sku_name = "Premium",
        },
    }
    redis_patch_schedule = {
        day_of_week = "Wednesday"
        start_hour_utc = 1
    }
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    storage_config = {
        common = {
            name = "binkuksouthprod",
            account_replication_type = "ZRS",
            account_tier = "Standard"
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
                delete_after_days = 180
            },
            {
                name = "backupsyearly",
                enabled = true,
                prefix_match = ["backups/yearly"],
                delete_after_days = 1095
            },
            {
                name = "bridge",
                enabled = true,
                prefix_match = ["bridge"],
                delete_after_days = 14
            }
        ]
    }
    cert_manager_zone_id = module.uksouth-dns.bink-sh[2]

    managed_identities = merge(local.managed_identities, { wasabireport = { kv_access = "ro" } })
}

module "uksouth_prod_rabbit" {
    source = "./uksouth/rabbitmq"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-prod-rabbitmq"
    location = "uksouth"
    tags = {
        "Environment" = "Production",
    }

    base_name = "prod-rabbitmq"
    vnet_cidr = "192.168.22.0/24"

    peering_remote_id = module.uksouth-firewall.vnet_id
    peering_remote_rg = module.uksouth-firewall.resource_group_name
    peering_remote_name = module.uksouth-firewall.vnet_name

    dns = module.uksouth-dns.private_dns

    cluster_cidrs = ["10.169.0.0/16"] # TODO: Uplift azurerm_cluster to output worker subnet ranges
}

module "uksouth_prod_cluster_0" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=2.4.6"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-prod-k0"
    cluster_name = "prod0"
    location = "uksouth"
    vnet_cidr = "10.169.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    bifrost_version = "4.8.5"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2s_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_count = 12
    max_pods_per_host = 30

    prometheus_subnet = "10.33.0.0/18"

    # Gitops repo, Managed identity for syncing common secrets
    flux_environment = "uksouth-prod"

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
    subscription_peers = {
        rabbitmq = {
            vnet_id = module.uksouth_prod_rabbit.peering["vnet_id"]
            vnet_name = module.uksouth_prod_rabbit.peering["vnet_name"]
            resource_group_name = module.uksouth_prod_rabbit.peering["resource_group_name"]
        }
    }

    firewall = {
        firewall_name = module.uksouth-firewall.firewall_name
        resource_group_name = module.uksouth-firewall.resource_group_name
        ingress_priority = 900
        rule_priority = 900
        public_ip = module.uksouth-firewall.public_ips.0.ip_address
        secure_origins = local.secure_origins
        developer_ips = local.developer_ips
        ingress_source = "*"
        ingress_http = 8000
        ingress_https = 4000
        ingress_controller = 6000
    }

    postgres_servers = module.uksouth_prod_environment.postgres_servers

    tags = {
        "Environment" = "Production",
    }
}

module "uksouth_prod_datawarehouse" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_datawarehouse.git?ref=0.3.8"
    providers = {
        azurerm = azurerm.uk_production
    }

    resource_group_name = "uksouth-prod-dwh"
    location = "uksouth"
    environment = "prod"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs2/authorizationRules/RootManageSharedAccessKey"
    tags = {
        "Environment" = "Production",
    }
    repo_name = "azure-synapse-prod"

    resource_group_iam = {
        ChrisSterritt = {
            object_id = local.aad_user.chris_sterritt,
            role = "Reader",
        }
    }
    storage_iam = {
        Architecture = {
            object_id = local.aad_group.architecture,
            role = "Contributor"
        }
        ChrisSterritt = {
            object_id = local.aad_user.chris_sterritt,
            role = "Contributor",
        }
    }
    sql_admin = local.aad_group.data_warehouse_admins
}
