module "uksouth_staging_environment" {
    source = "./modules/environment"
    providers = {
        azurerm = azurerm.uk_staging
    }
    resource_group_name = "uksouth-staging"
    location = "uksouth"
    tags = {
        "Environment" = "Staging",
    }

    resource_group_iam = {
        Backend = {
            object_id = "219194f6-b186-4146-9be7-34b731e19001",
            role = "Reader",
        },
        QA = {
            object_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d",
            role = "Reader",
        },
    }

    keyvault_users = {
        Backend = { object_id = "219194f6-b186-4146-9be7-34b731e19001" },
        QA = { object_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d" },
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-staging-common",
            sku_name = "GP_Gen5_4",
            storage_gb = 100,
            databases = ["*"]
        },
    }
    redis_config = {
        common = {
            name = "bink-uksouth-staging-common",
        },
    }
    storage_config = {
        common = {
            name = "binkuksouthstaging",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
}

module "uksouth_staging_cluster_0" {
    source = "./modules/cluster"
    providers = {
        azurerm = azurerm.uk_staging
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-staging-k0"
    cluster_name = "staging0"
    location = "uksouth"
    vnet_cidr = "10.128.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    worker_count = 3

    # Gitops repo, Managed identity for syncing common secrets
    gitops_repo = "git@git.bink.com:GitOps/uksouth-staging.git"
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
        ingress_priority = 600
        rule_priority = 600
        public_ip = module.uksouth-firewall.public_ips.1.ip_address
        secure_origins = local.secure_origins
        developer_ips = local.developer_ips
        ingress_source = "*"
        ingress_http = 8000
        ingress_https = 4000
        ingress_controller = 6000
    }

    postgres_servers = module.uksouth_staging_environment.postgres_servers

    tags = {
        "Environment" = "Staging",
    }
}
