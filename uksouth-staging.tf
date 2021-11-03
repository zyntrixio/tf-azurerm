module "uksouth_staging_environment" {
  source = "github.com/binkhq/tf-azurerm_environment?ref=2.5.4"
  providers = {
    azurerm = azurerm.uk_staging
  }
  resource_group_name = "uksouth-staging"
  location            = "uksouth"
  tags = {
    "Environment" = "Staging",
  }

  vnet_cidr = "192.168.100.0/24"

  postgres_iam = {}

  keyvault_iam = {
    Backend = {
      object_id = local.aad_group.backend,
      role      = "Reader",
    },
    QA = {
      object_id = local.aad_group.qa,
      role      = "Reader",
    },
  }

  storage_iam = {
    Backend = {
      storage_id = "common",
      object_id  = local.aad_group.backend,
      role       = "Contributor",
    },
    QA = {
      storage_id = "common",
      object_id  = local.aad_group.qa,
      role       = "Contributor",
    },
  }

  keyvault_users = {
    Backend = local.aad_group.backend,
    QA      = local.aad_group.qa,
  }

  postgres_config = {
    common = {
      name          = "bink-uksouth-staging-common",
      sku_name      = "GP_Gen5_4",
      storage_gb    = 500,
      public_access = true,
      databases     = ["*"]
    },
  }
  eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
  storage_config = {
    common = {
      name                     = "binkuksouthstaging",
      account_replication_type = "ZRS",
      account_tier             = "Standard"
      blob_endpoint            = "api.staging.gb.bink.com/content"
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

  eventhubs = {
    bink-uksouth-staging-loyalty = {
      name     = "loyalty" # => loyalty-history for kube secret name
      sku      = "Standard"
      capacity = 2

      eventhubs = {
        history = {
          partition_count   = 2
          message_retention = 4
        }
      }
    }
  }

  cert_manager_zone_id = module.uksouth-dns.bink-sh[2]

  managed_identities = local.managed_identities
}

module "uksouth_staging_cluster_0" {
  source = "github.com/binkhq/tf-azurerm_cluster?ref=2.10.2"
  providers = {
    azurerm      = azurerm.uk_staging
    azurerm.core = azurerm
  }

  resource_group_name  = "uksouth-staging-k0"
  cluster_name         = "staging0"
  location             = "uksouth"
  vnet_cidr            = "10.128.0.0/16"
  eventhub_authid      = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
  bifrost_version      = "4.13.0"
  ubuntu_version       = "20.04"
  controller_vm_size   = "Standard_D2as_v4"
  worker_vm_size       = "Standard_D4s_v4"
  worker_scaleset_size = 3
  use_scaleset         = true
  max_pods_per_host    = 100

  cluster_ingress_subdomains = [ "api", "web", "reflector", "policies" ]

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
    elasticsearch = {
      vnet_id             = module.uksouth-elasticsearch.vnet_id
      vnet_name           = module.uksouth-elasticsearch.vnet_name
      resource_group_name = module.uksouth-elasticsearch.resource_group_name
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
    developer_ips       = local.developer_ips
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
  source = "github.com/binkhq/tf-azurerm_binkweb?ref=1.2.2"
  providers = {
    azurerm      = azurerm.uk_staging
    azurerm.core = azurerm
  }

  resource_group_name = "uksouth-staging-web"
  location            = "uksouth"
  environment         = "staging"

  eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

  binkweb_dns_record = "web.staging.gb"
  public_dns_zone    = module.uksouth-dns.public_dns.bink_com

  ip_whitelist = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "20.49.163.188",
    "51.132.44.240/28",
  ]

  tags = {
    "Environment" = "Staging",
  }
}
