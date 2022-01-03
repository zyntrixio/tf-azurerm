module "uksouth_prod_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=2.6.5"
    providers = {
        azurerm = azurerm.uk_production
    }
    resource_group_name = "uksouth-prod"
    location = "uksouth"
    tags = {
        "Environment" = "Production",
    }

    vnet_cidr = "192.168.100.0/24"

    postgres_iam = {
        ChrisLatham = {
            object_id = local.aad_user.chris_latham,
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
        qa = {
            object_id = local.aad_group.qa,
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
        qa = local.aad_group.qa,
    }

    postgres_flexible_config = {
        common = {
            name = "bink-uksouth-prod"
            version = "13"
            sku_name = "GP_Standard_D8ds_v4"
            storage_mb = 1048576
            high_availability = true
            databases = [
                "atlas",
                "eos",
                "europa",
                "hades",
                "harmonia",
                "hermes",
                "midas",
                "pontus",
                "postgres",
                "zagreus",
            ]
        },
        tableau = {
            name = "bink-uksouth-tableau"
            version = "13"
            sku_name = "GP_Standard_D4ds_v4"
            storage_mb = 1048576
            high_availability = false
            databases = [
                "postgres",
            ]
        },
    }

    redis_config = {
        vnet = { name = "bink-uksouth-prod" }
    }
    redis_patch_schedule = {
        day_of_week    = "Wednesday"
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
            },
            {
                name = "data-management",
                enabled = true,
                prefix_match = ["data-management"],
                delete_after_days = 1
            },
        ]
    }
    cert_manager_zone_id = module.uksouth-dns.bink-sh[2]

    managed_identities = merge(local.managed_identities, { wasabireport = { kv_access = "ro" } })

    secret_namespaces = "default,monitoring,datamanagement,backups,tableau"
}

module "uksouth_prod_tableau" {
    source = "./uksouth/tableau2"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }

    firewall = {
        vnet_id = module.uksouth-firewall.vnet_id,
        vnet_name = module.uksouth-firewall.vnet_name,
        resource_group_name = module.uksouth-firewall.resource_group_name,
    }
    environment = {
        vnet_id = module.uksouth_prod_environment.peering.vnet_id
        vnet_name = module.uksouth_prod_environment.peering.vnet_name
        resource_group_name = module.uksouth_prod_environment.peering.resource_group_name
    }
    postgres_flexible_server_dns_link = module.uksouth_prod_environment.postgres_flexible_server_dns_link
    loganalytics_id                   = module.uksouth_loganalytics.loganalytics_id
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

    cluster_cidrs = ["10.169.0.0/16", "10.170.0.0/16"] # TODO: Uplift azurerm_cluster to output worker subnet ranges
}

module "uksouth_prod_cluster_0" {
    source = "github.com/binkhq/tf-azurerm_cluster?ref=2.11.3"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-prod-k0"
    cluster_name = "prod0"
    location = "uksouth"
    vnet_cidr = "10.169.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    bifrost_version = "4.19.0"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2as_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_scaleset_size = 6
    use_scaleset = true
    max_pods_per_host = 100

    cluster_ingress_subdomains = local.prod_cluster_ingress_subdomains

    prometheus_subnet = "10.33.0.0/18"

    # Gitops repo, Managed identity for syncing common secrets
    flux_environment = "uksouth-prod"

    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity

    # DNS zones
    private_dns = module.uksouth-dns.private_dns
    public_dns  = module.uksouth-dns.public_dns

    # Peers    
    peers = {
        firewall = {
            vnet_id             = module.uksouth-firewall.vnet_id
            vnet_name           = module.uksouth-firewall.vnet_name
            resource_group_name = module.uksouth-firewall.resource_group_name
        }
        elasticsearch = {
            vnet_id             = module.uksouth-elasticsearch.vnet_id
            vnet_name           = module.uksouth-elasticsearch.vnet_name
            resource_group_name = module.uksouth-elasticsearch.resource_group_name
        }
    }
    subscription_peers = {
        rabbitmq = {
            vnet_id = module.uksouth_prod_rabbit.peering["vnet_id"]
            vnet_name = module.uksouth_prod_rabbit.peering["vnet_name"]
            resource_group_name = module.uksouth_prod_rabbit.peering["resource_group_name"]
        }
        environment = {
            vnet_id = module.uksouth_prod_environment.peering.vnet_id
            vnet_name = module.uksouth_prod_environment.peering.vnet_name
            resource_group_name = module.uksouth_prod_environment.peering.resource_group_name
        }
    }

    firewall = {
        firewall_name = module.uksouth-firewall.firewall_name
        resource_group_name = module.uksouth-firewall.resource_group_name
        ingress_priority = 1000
        rule_priority = 1000
        public_ip = module.uksouth-firewall.public_ips.0.ip_address
        secure_origins = local.secure_origins
        ingress_source = "*"
        ingress_http = 8000
        ingress_https = 4000
        ingress_controller = 6000
    }

    postgres_servers = module.uksouth_prod_environment.postgres_servers
    postgres_flexible_server_dns_link = module.uksouth_prod_environment.postgres_flexible_server_dns_link

    tags = {
        "Environment" = "Production",
    }
}

module "uksouth_prod_cluster_1" {
    source = "github.com/binkhq/tf-azurerm_cluster?ref=2.11.3"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-prod-k1"
    cluster_name = "prod1"
    location = "uksouth"
    vnet_cidr = "10.170.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    bifrost_version = "4.19.0"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2as_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_scaleset_size = 6
    use_scaleset = true
    max_pods_per_host = 100

    cluster_ingress_subdomains = local.prod_cluster_ingress_subdomains

    prometheus_subnet = "10.33.0.0/18"

    # Gitops repo, Managed identity for syncing common secrets
    flux_environment = "uksouth-prod"

    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity

    # DNS zones
    private_dns = module.uksouth-dns.private_dns
    public_dns  = module.uksouth-dns.public_dns

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
        environment = {
            vnet_id = module.uksouth_prod_environment.peering.vnet_id
            vnet_name = module.uksouth_prod_environment.peering.vnet_name
            resource_group_name = module.uksouth_prod_environment.peering.resource_group_name
        }
    }

    firewall = {
        firewall_name = module.uksouth-firewall.firewall_name
        resource_group_name = module.uksouth-firewall.resource_group_name
        ingress_priority = 1001
        rule_priority = 1001
        public_ip = module.uksouth-firewall.public_ips.0.ip_address
        secure_origins = local.secure_origins
        ingress_source = "*"
        ingress_http = 8001
        ingress_https = 4001
        ingress_controller = 6001
    }

    postgres_servers = module.uksouth_prod_environment.postgres_servers
    postgres_flexible_server_dns_link = module.uksouth_prod_environment.postgres_flexible_server_dns_link

    tags = {
        "Environment" = "Production",
    }
}

module "uksouth_prod_binkweb" {
    source = "github.com/binkhq/tf-azurerm_binkweb?ref=2.0.0"
    providers = {
        azurerm = azurerm.uk_production
    }
    resource_group_name = "uksouth-prod"
    location = "uksouth"
    environment = "Production"

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    loganalytics_id = module.uksouth_loganalytics.loganalytics_id

    storage_accounts = {
        wallet = {
            name = "binkwebprodbink"
        }
        wasabi = {
            name = "binkwebprodwasabi"
        }
        fatface = {
            name = "binkwebprodfatface"
        }
    }
}
