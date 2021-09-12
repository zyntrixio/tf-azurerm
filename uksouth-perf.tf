module "uksouth_performance_environment" {
  source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=2.3.1"
  providers = {
    azurerm = azurerm.uk_sandbox
  }
  resource_group_name = "uksouth-perf"
  location            = "uksouth"
  tags = {
    "Environment" = "Performance",
  }

  postgres_iam = {
    ChrisSterritt = {
      object_id = local.aad_user.chris_sterritt,
      role      = "Contributor",
    },
    Backend = {
      object_id = local.aad_group.backend,
      role      = "Contributor",
    },
    QA = {
      object_id = local.aad_group.qa,
      role      = "Contributor",
    },
  }

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
      name          = "bink-uksouth-perf-common",
      sku_name      = "GP_Gen5_4",
      storage_gb    = 3000,
      public_access = false,
      databases     = ["*"]
    },
  }
  redis_config = {
    common = {
      name     = "bink-uksouth-perf-common",
      family   = "C",
      sku_name = "Standard",
    },
  }

  redis_enterprise_config = {}

  redis_patch_schedule = {
    day_of_week    = "Monday"
    start_hour_utc = 1
  }
  eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
  storage_config = {
    common = {
      name                     = "binkuksouthperf",
      account_replication_type = "ZRS",
      account_tier             = "Standard"
    },
  }
  cert_manager_zone_id = module.uksouth-dns.bink-sh[2]

  managed_identities = local.managed_identities
}

module "uksouth_performance_rabbit" {
  source = "./uksouth/rabbitmq"
  providers = {
    azurerm      = azurerm.uk_sandbox
    azurerm.core = azurerm
  }

  resource_group_name = "uksouth-perf-rabbitmq"
  location            = "uksouth"
  tags = {
    "Environment" = "Performance",
  }

  base_name = "perf-rabbitmq"
  vnet_cidr = "192.168.21.0/24"

  peering_remote_id   = module.uksouth-firewall.vnet_id
  peering_remote_rg   = module.uksouth-firewall.resource_group_name
  peering_remote_name = module.uksouth-firewall.vnet_name

  dns = module.uksouth-dns.private_dns

  cluster_cidrs = ["10.43.0.0/16"] # TODO: Uplift azurerm_cluster to output worker subnet ranges
}


module "uksouth_performance_cluster_0" {
  source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=2.8.1"
  providers = {
    azurerm      = azurerm.uk_sandbox
    azurerm.core = azurerm
  }

  resource_group_name  = "uksouth-perf-k0"
  cluster_name         = "perf0"
  location             = "uksouth"
  vnet_cidr            = "10.43.0.0/16"
  eventhub_authid      = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
  bifrost_version      = "4.9.2"
  ubuntu_version       = "20.04"
  controller_vm_size   = "Standard_D2as_v4"
  worker_vm_size       = "Standard_D4s_v4"
  worker_scaleset_size = 3
  use_scaleset         = true
  max_pods_per_host    = 100

  prometheus_subnet = "10.33.0.0/18"

  # Gitops repo, Managed identity for syncing common secrets
  flux_environment = "uksouth-perf"

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
    rabbitmq = {
      vnet_id             = module.uksouth_performance_rabbit.peering["vnet_id"]
      vnet_name           = module.uksouth_performance_rabbit.peering["vnet_name"]
      resource_group_name = module.uksouth_performance_rabbit.peering["resource_group_name"]
    }
  }

  firewall = {
    firewall_name       = module.uksouth-firewall.firewall_name
    resource_group_name = module.uksouth-firewall.resource_group_name
    ingress_priority    = 1600
    rule_priority       = 1600
    public_ip           = module.uksouth-firewall.public_ips.6.ip_address
    secure_origins      = local.secure_origins
    developer_ips       = local.developer_ips
    ingress_source      = "*"
    ingress_http        = 8000
    ingress_https       = 4000
    ingress_controller  = 6000
  }

  postgres_servers = module.uksouth_performance_environment.postgres_servers
  private_links    = module.uksouth_performance_environment.private_links

  tags = {
    "Environment" = "Performance",
  }

  vmss_iam = {
    Backend = {
      object_id = local.aad_group.backend,
      role      = "Contributor",
    },
    QA = {
      object_id = local.aad_group.qa,
      role      = "Contributor",
    },
  }
}
