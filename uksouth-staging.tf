module "uksouth_staging_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.1.2"
    providers = {
        azurerm = azurerm.uk_staging
        azurerm.core = azurerm
    }
    resource_group_name = "uksouth-staging"
    location = "uksouth"
    tags = {
        "Environment" = "Staging",
    }

    vnet_cidr = "192.168.100.0/24"

    loganalytics_id = module.uksouth_loganalytics.id

    postgres_iam = {}

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
        SecOps = local.aad_group.cyber_sec,
    }

    postgres_flexible_config = {
        common = {
            name = "bink-uksouth-staging"
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
            name                     = "binkuksouthstaging",
            account_replication_type = "ZRS",
            account_tier             = "Standard"
        }
    }
    storage_management_policy_config = {
        common = [
            {
                name              = "backupshourly",
                enabled           = true,
                prefix_match      = ["backups/hourly"],
                delete_after_days = 30
            },
            {
                name              = "backupsweekly",
                enabled           = true,
                prefix_match      = ["backups/weekly"],
                delete_after_days = 90
            },
            {
                name              = "backupsyearly",
                enabled           = true,
                prefix_match      = ["backups/yearly"],
                delete_after_days = 1095
            }
        ]
    }

    bink_sh_zone_id = module.uksouth-dns.bink-sh[2]
    bink_host_zone_id = module.uksouth-dns.bink-host[2]

    managed_identities = local.managed_identities

    secret_namespaces = "default,portal,bpl,bpl-testing,monitoring,backups"
}

module "uksouth_staging_cluster_0" {
  source = "github.com/binkhq/tf-azurerm_cluster?ref=2.17.0"
  providers = {
    azurerm      = azurerm.uk_staging
    azurerm.core = azurerm
  }

  resource_group_name  = "uksouth-staging-k0"
  cluster_name         = "staging0"
  location             = "uksouth"
  vnet_cidr            = "10.128.0.0/16"
  eventhub_authid      = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
  bifrost_version      = "4.23.0"
  ubuntu_version       = "20.04"
  controller_vm_size   = "Standard_D2as_v4"
  worker_vm_size       = "Standard_D4s_v4"
  worker_scaleset_size = 5
  use_scaleset         = true
  max_pods_per_host    = 100
  loganalytics_id = module.uksouth_loganalytics.id
  controller_storage_type = "StandardSSD_LRS"

  cluster_ingress_subdomains = [ "api", "bpl", "link", "web", "reflector", "policies", "api2-docs", "portal", "help" ]

  prometheus_subnet = "10.33.0.0/18"

  flux_environment = "uksouth-staging"

  common_keyvault               = data.terraform_remote_state.uksouth-common.outputs.keyvault
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
  }
  subscription_peers = {
    environment = {
      vnet_id = module.uksouth_staging_environment.peering.vnet_id
      vnet_name = module.uksouth_staging_environment.peering.vnet_name
      resource_group_name = module.uksouth_staging_environment.peering.resource_group_name
    }
  }

  firewall = {
    firewall_name       = module.uksouth-firewall.firewall_name
    resource_group_name = module.uksouth-firewall.resource_group_name
    ingress_priority    = 1200
    rule_priority       = 1200
    public_ip           = module.uksouth-firewall.public_ips.2.ip_address
    secure_origins      = local.secure_origins
    ingress_source      = "*"
    ingress_http        = 8000
    ingress_https       = 4000
    ingress_controller  = 6000
  }

  postgres_servers = module.uksouth_staging_environment.postgres_servers
  postgres_flexible_server_dns_link = module.uksouth_staging_environment.postgres_flexible_server_dns_link

  tags = {
    "Environment" = "Staging",
  }
}

module "uksouth_staging_binkweb" {
    source = "github.com/binkhq/tf-azurerm_binkweb?ref=2.1.1"
    providers = {
        azurerm = azurerm.uk_staging
    }
    resource_group_name = "uksouth-staging"
    location = "uksouth"
    environment = "Staging"

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    loganalytics_id = module.uksouth_loganalytics.id

    storage_accounts = {
        wallet = {
            name = "binkwebstagingbink"
        }
        wasabi = {
            name = "binkwebstagingwasabi"
        }
        fatface = {
            name = "binkwebstagingfatface"
        }
    }
}
