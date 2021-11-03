module "uksouth_sandbox_environment" {
  source = "github.com/binkhq/tf-azurerm_environment?ref=2.5.5"
  providers = {
    azurerm = azurerm.uk_sandbox
  }
  resource_group_name = "uksouth-sandbox"
  location            = "uksouth"
  tags = {
    "Environment" = "Sandbox",
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
    Common-Backend = {
      storage_id = "common",
      object_id  = local.aad_group.backend,
      role       = "Contributor",
    },
    Sit-Backend = {
      storage_id = "sit",
      object_id  = local.aad_group.backend,
      role       = "Contributor",
    },
    Oat-Backend = {
      storage_id = "oat",
      object_id  = local.aad_group.backend,
      role       = "Contributor",
    },
    Common-QA = {
      storage_id = "common",
      object_id  = local.aad_group.qa,
      role       = "Contributor",
    },
    Sit-QA = {
      storage_id = "sit",
      object_id  = local.aad_group.qa,
      role       = "Contributor",
    },
    Oat-QA = {
      storage_id = "oat",
      object_id  = local.aad_group.qa,
      role       = "Contributor",
    },
  }

  keyvault_users = {
    Backend = local.aad_group.backend,
    QA      = local.aad_group.qa,
  }

  additional_keyvaults = [
    "bink-uksouth-sandbox-sit",
    "bink-uksouth-sandbox-oat"
  ]

  postgres_flexible_config = {
    common = {
      name = "bink-uksouth-sandbox"
      version = "13"
      sku_name = "GP_Standard_D2s_v3"
      storage_mb = 131072
      high_availability = false
        databases = [
          "postgres",
          "lbg_atlas",
          "lbg_europa",
          "lbg_hades",
          "lbg_hermes",
          "lbg_midas",
          "lbg_pontus",
        ]
    }
  }

  postgres_config = {
    common = {
      name          = "bink-uksouth-sandbox-common",
      sku_name      = "GP_Gen5_4",
      storage_gb    = 1000,
      public_access = true,
      databases     = ["*"]
    },
  }

  secret_namespaces = "default,oat,sit-barclays,sit-lbg,monitoring"
  eventhub_authid   = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
  storage_config = {
    common = {
      name                     = "binkuksouthsandbox",
      account_replication_type = "ZRS",
      account_tier             = "Standard"
    },
    sit = {
      name                     = "binkuksouthsandboxsit",
      account_replication_type = "ZRS",
      account_tier             = "Standard"
    },
    oat = {
      name                     = "binkuksouthsandboxoat",
      account_replication_type = "ZRS",
      account_tier             = "Standard"
    },
    sit-lbg = {
      name                     = "binkuksouthsandboxsitlbg",
      account_replication_type = "ZRS",
      account_tier             = "Standard"
    },
  }
  cert_manager_zone_id = module.uksouth-dns.bink-sh[2]

  managed_identities = local.managed_identities
}

module "uksouth_sandbox_cluster_0" {
  source = "github.com/binkhq/tf-azurerm_cluster?ref=2.10.2"
  providers = {
    azurerm      = azurerm.uk_sandbox
    azurerm.core = azurerm
  }

  resource_group_name  = "uksouth-sandbox-k0"
  cluster_name         = "sandbox0"
  location             = "uksouth"
  vnet_cidr            = "10.189.0.0/16"
  eventhub_authid      = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
  bifrost_version      = "4.13.0"
  ubuntu_version       = "20.04"
  controller_vm_size   = "Standard_D2as_v4"
  worker_vm_size       = "Standard_D4s_v4"
  worker_scaleset_size = 3
  use_scaleset         = true
  max_pods_per_host    = 100

  cluster_ingress_subdomains = [ "sit", "oat", "web" ]

  prometheus_subnet = "10.33.0.0/18"

  flux_environment = "uksouth-sandbox"

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
      vnet_id = module.uksouth_sandbox_environment.peering.vnet_id
      vnet_name = module.uksouth_sandbox_environment.peering.vnet_name
      resource_group_name = module.uksouth_sandbox_environment.peering.resource_group_name
    }
  }

  firewall = {
    firewall_name       = module.uksouth-firewall.firewall_name
    resource_group_name = module.uksouth-firewall.resource_group_name
    ingress_priority    = 1400
    rule_priority       = 1400
    public_ip           = module.uksouth-firewall.public_ips.4.ip_address
    secure_origins      = local.secure_origins
    developer_ips       = local.developer_ips
    ingress_source      = "*"
    ingress_http        = 8000
    ingress_https       = 4000
    ingress_controller  = 6000
  }

  postgres_servers = module.uksouth_sandbox_environment.postgres_servers
  postgres_flexible_server_dns_link = module.uksouth_sandbox_environment.postgres_flexible_server_dns_link

  tags = {
    "Environment" = "Sandbox",
  }
}

module "uksouth_sandbox_binkweb" {
  source = "github.com/binkhq/tf-azurerm_binkweb?ref=1.2.2"
  providers = {
    azurerm      = azurerm.uk_sandbox
    azurerm.core = azurerm
  }

  resource_group_name = "uksouth-sandbox-web"
  location            = "uksouth"
  environment         = "sandbox"

  eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

  binkweb_dns_record = "web.sandbox.gb"
  public_dns_zone    = module.uksouth-dns.public_dns.bink_com

  ip_whitelist = [
    "0.0.0.0/0",
  ]

  tags = {
    "Environment" = "Sandbox",
  }
}
