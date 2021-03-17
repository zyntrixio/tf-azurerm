module "uksouth_prod_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=1.7.3"
    providers = {
        azurerm = azurerm.uk_production
    }
    resource_group_name = "uksouth-prod"
    location = "uksouth"
    tags = {
        "Environment" = "Production",
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
        MickLatham = { object_id = "343299d4-0a39-4109-adce-973ad29d0183" },
        ChrisLatham = { object_id = "607482a3-07fa-4b24-8af0-5b84df6ca7c6" },
        ChristianPrior = { object_id = "ae282437-d730-4342-8914-c936e8289cdc" },
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

    additional_managed_identities = {
        wasabireport = {
            keyvault_permissions = ["get"]
        }
    }
    cert_manager_zone_id = module.uksouth-dns.bink-sh[2]
}

module "uksouth_prod_cluster_0" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=2.3.1"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-prod-k0"
    cluster_name = "prod0"
    location = "uksouth"
    vnet_cidr = "10.169.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    bifrost_version = "4.6.3"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2s_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_count = 12

    prometheus_subnet = "10.33.0.0/18"

    # Gitops repo, Managed identity for syncing common secrets
    gitops_repo = "git@git.bink.com:GitOps/uksouth-prod.git"
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
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_datawarehouse.git?ref=0.2.0"
    providers = {
        azurerm = azurerm.uk_production
    }

    resource_group_name = "uksouth-prod-dwh"
    location = "uksouth"
    environment = "prod"
    tags = {
        "Environment" = "Production",
    }
    repo_name = "azure-synapse-prod"

    resource_group_iam = {
        Architecture = {
            object_id = "fb26c586-72a5-4fbc-b2b0-e1c28ef4fce1",
            role = "Reader"
        }
    }
    sql_admin = "34985102-e792-4f5c-ac22-4aa72fc721bf"
}
