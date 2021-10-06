module "uksouth_dev_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=2.4.1"
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
        ChrisSterritt = {
            object_id = local.aad_user.chris_sterritt,
            role = "Contributor",
        },
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
    }

    infra_keyvault_users = {
        AzureSynapse = { object_id = module.uksouth_dev_datawarehouse.synapse_identity.principal_id, permissions = ["get"] }
    }

    postgres_flexible_config = {
        common = {
            name = "bink-uksouth-dev"
            version = "13"
            sku_name = "GP_Standard_D2s_v3"
            storage_mb = 131072
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

    postgres_config = {
        common = {
            name = "bink-uksouth-dev-common",
            sku_name = "GP_Gen5_4",
            storage_gb = 500,
            public_access = true,
            databases = ["*"]
        },
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

    eventhubs = {
        bink-uksouth-dev-loyalty = {
            name = "loyalty" # => loyalty-history for kube secret name
            sku = "Standard"
            capacity = 2

            eventhubs = {
                history = {
                    partition_count = 2
                    message_retention = 4
                }
            }
        }
    }

    cert_manager_zone_id = module.uksouth-dns.bink-sh[2]

    managed_identities = local.managed_identities
}

module "uksouth_dev_cluster_0" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=2.10.0"
    providers = {
        azurerm      = azurerm.uk_dev
        azurerm.core = azurerm
    }

    resource_group_name  = "uksouth-dev-k0"
    cluster_name = "dev0"
    location = "uksouth"
    vnet_cidr = "10.99.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    bifrost_version = "4.12.2"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2as_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_scaleset_size = 3
    use_scaleset = true
    max_pods_per_host = 100

    cluster_ingress_subdomains = [ "api", "web", "reflector" ]

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
        developer_ips = local.developer_ips
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

module "uksouth_dev_datawarehouse" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_datawarehouse.git?ref=0.4.0"
    providers = {
        azurerm = azurerm.uk_dev
    }

    resource_group_name = "uksouth-dev-dwh"
    location            = "uksouth"
    environment         = "dev"
    eventhub_authid     = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs2/authorizationRules/RootManageSharedAccessKey"
    tags = {
        "Environment" = "Dev",
    }
    repo_name = "azure-synapse-dev"

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
    sql_admin = local.aad_group.data_warehouse_admins # Data Warehouse Admins group
}

module "uksouth_dev_binkweb" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_binkweb.git?ref=1.2.2"
    providers = {
        azurerm      = azurerm.uk_dev
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-dev-web"
    location = "uksouth"
    environment = "dev"

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

    binkweb_dns_record = "web.dev.gb"
    public_dns_zone = module.uksouth-dns.public_dns.bink_com

    ip_whitelist = [
        "10.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16",
        "20.49.163.188",
        "51.132.44.240/28",
    ]

    tags = {
        "Environment" = "Development",
    }
}
