module "uksouth_dev_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=2.6.5"
    providers = {
        azurerm = azurerm.uk_dev
    }
    resource_group_name = "uksouth-dev"
    location = "uksouth"
    tags = {
        "Environment" = "Dev",
    }

    vnet_cidr = "192.168.100.0/24"

    postgres_iam = {
        Backend = {
            object_id = local.aad_group.backend,
            role = "Reader",
        },
    }

    keyvault_iam = {
        Backend = {
            object_id = local.aad_group.backend,
            role = "Reader",
        },
        QA = {
            object_id = local.aad_group.qa,
            role = "Reader",
        },
    }

    storage_iam = {
        Backend = {
            storage_id = "common",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        QA = {
            storage_id = "common",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
    }

    keyvault_users = {
        Backend = local.aad_group.backend,
        QA = local.aad_group.qa,
        Architecture = local.aad_group.architecture
    }

    postgres_flexible_config = {
        common = {
            name = "bink-uksouth-dev"
            version = "13"
            sku_name = "GP_Standard_D2ds_v4"
            storage_mb = 131072
            high_availability = false
            databases = [
                "api_reflector",
                "atlas",
                "carina",
                "eos",
                "europa",
                "hades",
                "harmonia",
                "helios",
                "hermes",
                "midas",
                "polaris",
                "pontus",
                "postgres",
                "vela",
                "zagreus",
            ]
        }
    }

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    storage_config = {
        common = {
            name                     = "binkuksouthdev",
            account_replication_type = "ZRS",
            account_tier             = "Standard"
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

    secret_namespaces = "default,monitoring,backups"
}

module "uksouth_dev_cluster_0" {
    source = "github.com/binkhq/tf-azurerm_cluster?ref=2.11.3"
    providers = {
        azurerm      = azurerm.uk_dev
        azurerm.core = azurerm
    }

    resource_group_name  = "uksouth-dev-k0"
    cluster_name = "dev0"
    location = "uksouth"
    vnet_cidr = "10.99.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    bifrost_version = "4.16.0"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2as_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_scaleset_size = 3
    use_scaleset = true
    max_pods_per_host = 100

    cluster_ingress_subdomains = [ "api", "web", "reflector", "api2-docs" ]

    prometheus_subnet = "10.33.0.0/18"

    flux_environment = "uksouth-dev"

    # Gitops repo, Managed identity for syncing common secrets

    common_keyvault               = data.terraform_remote_state.uksouth-common.outputs.keyvault
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
        environment = {
            vnet_id = module.uksouth_dev_environment.peering.vnet_id
            vnet_name = module.uksouth_dev_environment.peering.vnet_name
            resource_group_name = module.uksouth_dev_environment.peering.resource_group_name
        }
    }

    firewall = {
        firewall_name = module.uksouth-firewall.firewall_name
        resource_group_name = module.uksouth-firewall.resource_group_name
        ingress_priority = 1300
        rule_priority = 1300
        public_ip = module.uksouth-firewall.public_ips.3.ip_address
        secure_origins = local.secure_origins
        ingress_source = "*"
        ingress_http = 8000
        ingress_https = 4000
        ingress_controller = 6000
    }

    postgres_servers = module.uksouth_dev_environment.postgres_servers
    postgres_flexible_server_dns_link = module.uksouth_dev_environment.postgres_flexible_server_dns_link
    # private_links = module.uksouth_dev_environment.private_links

    tags = {
        "Environment" = "Development",
    }
}

module "uksouth_dev_binkweb" {
    source = "github.com/binkhq/tf-azurerm_binkweb?ref=2.0.0"
    providers = {
        azurerm = azurerm.uk_dev
    }
    resource_group_name = "uksouth-dev"
    location = "uksouth"
    environment = "Development"

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    loganalytics_id = module.uksouth_loganalytics.loganalytics_id

    storage_accounts = {
        wallet = {
            name = "binkwebdevbink"
        }
        wasabi = {
            name = "binkwebdevwasabi"
        }
        fatface = {
            name = "binkwebdevfatface"
        }
    }
}
