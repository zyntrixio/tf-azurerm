module "uksouth_preprod_environment" {
    source = "./modules/environment"
    providers = {
        azurerm = azurerm.uk_preprod
    }
    resource_group_name = "uksouth-preprod"
    location = "uksouth"
    tags = {
        "Environment" = "Pre-Production",
    }

    resource_group_iam = {
        Backend = {
            object_id = "219194f6-b186-4146-9be7-34b731e19001",
            role = "Reader",
        },
        MickLatham = {
            object_id = "343299d4-0a39-4109-adce-973ad29d0183",
            role = "Contributor",
        },
        ChrisLatham = {
            object_id = "607482a3-07fa-4b24-8af0-5b84df6ca7c6",
            role = "Contributor",
        },
        ChristianPrior = {
            object_id = "ae282437-d730-4342-8914-c936e8289cdc",
            role = "Contributor",
        },
    }

    keyvault_users = {
        Backend = { object_id = "219194f6-b186-4146-9be7-34b731e19001" },
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-preprod-common",
            sku_name = "GP_Gen5_2",
            storage_gb = 100,
            databases = ["atlas", "europa", "pontus", "thanatos", "zagreus"]
        },
        hermes = {
            name = "bink-uksouth-preprod-hermes",
            sku_name = "GP_Gen5_2",
            storage_gb = 100,
            databases = ["hermes"]
        },
        hades = {
            name = "bink-uksouth-preprod-hades",
            sku_name = "GP_Gen5_2",
            storage_gb = 100,
            databases = ["hades"]
        },
        harmonia = {
            name = "bink-uksouth-preprod-harmonia",
            sku_name = "GP_Gen5_4",
            storage_gb = 100,
            databases = ["harmonia"]
        },
    }
    redis_config = {
        common = {
            name = "bink-uksouth-preprod-common",
        },
    }
    redis_patch_schedule = {
        day_of_week = "Wednesday"
        start_hour_utc = 1
    }
    storage_config = {
        common = {
            name = "binkuksouthpreprod",
            account_replication_type = "ZRS",
        },
    }
}

output "uksouth_preprod_managedidentites" {
    value = module.uksouth_preprod_environment.managedidentites
    sensitive = false
}

module "uksouth_preprod_cluster_1" {
    source = "./modules/cluster"
    providers = {
        azurerm = azurerm.uk_preprod
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-preprod-k1"
    cluster_name = "preprod0"
    location = "uksouth"
    vnet_cidr = "10.69.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    worker_count = 5

    # Gitops repo, Managed identity for syncing common secrets
    gitops_repo = "git@git.bink.com:GitOps/uksouth-preprod.git"
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
        ingress_priority = 800
        rule_priority = 800
        public_ip = module.uksouth-firewall.public_ips.15.ip_address
        secure_origins = local.secure_origins
        developer_ips = local.developer_ips
        ingress_source = "*"
        ingress_http = 8000
        ingress_https = 4000
        ingress_controller = 6000
    }

    postgres_servers = module.uksouth_preprod_environment.postgres_servers

    tags = {
        "Environment" = "Pre-Production",
    }
}
