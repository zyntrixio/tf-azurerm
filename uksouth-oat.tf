module "uksouth_oat_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=1.1.0"
    providers = {
        azurerm = azurerm.uk_sandbox
    }
    resource_group_name = "uksouth-oat"
    location = "uksouth"
    tags = {
        "Environment" = "Barclays OAT",
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
        ChristianPrior = { object_id = "ae282437-d730-4342-8914-c936e8289cdc" },
        KashimAziz = { object_id = "b004c980-3e08-4237-b8e2-d6e65d2bef3f" },
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-oat-common",
            sku_name = "GP_Gen5_4",
            storage_gb = 1000,
            databases = ["*"]
        },
    }
    redis_config = {
        common = {
            name = "bink-uksouth-oat-common",
        },
    }
    redis_patch_schedule = {
        day_of_week = "Wednesday"
        start_hour_utc = 1
    }
    storage_config = {
        common = {
            name = "binkuksouthoat",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
}

module "uksouth_oat_cluster_0" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=1.5.0"
    providers = {
        azurerm = azurerm.uk_sandbox
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-oat-k0"
    cluster_name = "oat0"
    location = "uksouth"
    vnet_cidr = "10.188.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    bifrost_version = "4.6.1"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2s_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_count = 4

    prometheus_subnet = "10.33.0.0/18"

    # Gitops repo, Managed identity for syncing common secrets
    gitops_repo = "git@git.bink.com:GitOps/uksouth-oat.git"
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
        ingress_priority = 1190
        rule_priority = 1190
        public_ip = module.uksouth-firewall.public_ips.4.ip_address
        secure_origins = local.secure_origins
        developer_ips = local.developer_ips
        ingress_source = "*"
        ingress_http = 8090
        ingress_https = 4090
        ingress_controller = 6090
    }

    postgres_servers = module.uksouth_oat_environment.postgres_servers

    tags = {
        "Environment" = "Barclays OAT",
    }
}
