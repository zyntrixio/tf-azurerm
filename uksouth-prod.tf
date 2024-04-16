## TODO: Assign Snowstorm identity to Log Analytics automatically.

module "uksouth_prod" {
  source = "./cluster"
  providers = {
    azurerm      = azurerm.uksouth_production
    azurerm.core = azurerm
  }
  common = {
    name     = "prod"
    location = "uksouth"
    cidr     = "10.11.0.0/16"
  }
  frontdoor = {
    profile = module.uksouth_frontdoor.profile
    domains = {
      "api.gb.bink.com" = {
        origin_fqdn = "api.prod.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-gb-bink-com"]
        waf = {
          enforced      = false
          managed_rules = { Microsoft_DefaultRuleSet = { version = "2.1", action = "Log" } }
          custom_rules = {
            zephyrus_amex = {
              action = "Log"
              match_conditions = [
                {
                  match_variable = "RequestUri"
                  operator       = "Equal"
                  match_values   = ["/auth_transactions/authorize", "/auth_transactions/amex", "/auth_transactions/amex/settlement"]
                },
                {
                  match_variable     = "RemoteAddr"
                  operator           = "IPMatch"
                  negation_condition = true
                  match_values       = local.amex_origins
                },
              ]
            }
            zephyrus_visa = {
              action = "Log"
              match_conditions = [
                {
                  match_variable = "RequestUri"
                  operator       = "Equal"
                  match_values   = ["/auth_transactions/visa"]
                },
                {
                  match_variable     = "RemoteAddr"
                  operator           = "IPMatch"
                  negation_condition = true
                  match_values       = local.visa_origins
                },
              ]
            }
            zephyrus_mastercard = {
              action = "Log"
              match_conditions = [
                {
                  match_variable = "RequestUri"
                  operator       = "Equal"
                  match_values   = ["/auth_transactions/mastercard"]
                },
                {
                  match_variable     = "RemoteAddr"
                  operator           = "IPMatch"
                  negation_condition = true
                  match_values       = local.mastercard_origins
                },
              ]
            }
          }
        }
      }
      "docs.gb.bink.com" = {
        origin_fqdn = "docs.prod.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-gb-bink-com"]
      }
      "bpl.gb.bink.com" = {
        origin_fqdn = "bpl.prod.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-gb-bink-com"]
      }
      "rewards.gb.bink.com" = {
        origin_fqdn = "rewards.prod.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-gb-bink-com"]
      }
      "policies.gb.bink.com" = {
        origin_fqdn = "policies.prod.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-gb-bink-com"]
      }
      "portal.gb.bink.com" = {
        origin_fqdn = "portal.prod.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-gb-bink-com"]
      }
      "retailer.gb.bink.com" = {
        origin_fqdn = "retailer.prod.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-gb-bink-com"]
      }
      "tableau.gb.bink.com" = {
        origin_fqdn = "tableau.prod.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-gb-bink-com"]
      }
    }
  }
  backups = {
    resource_id  = module.uksouth_backups.resource_id
    principal_id = module.uksouth_backups.principal_id
    policies     = module.uksouth_backups.policies
  }
  dns = {
    id                  = module.uksouth_dns.bink_sh_id
    zone_name           = module.uksouth_dns.bink_com_zone
    resource_group_name = module.uksouth_dns.resource_group_name
  }
  acr = { id = module.uksouth_core.acr_id }
  allowed_hosts = {
    ipv4 = concat(local.secure_origins)
    ipv6 = concat(local.secure_origins_v6)
  }
  iam = {
    (local.aad_user.terraform)                            = { assigned_to = ["kv_su"] }
    (local.entra_users["cpressland@bink.com"].object_id)  = { assigned_to = ["kv_su", "st_rw"] }
    (local.entra_users["nread@bink.com"].object_id)       = { assigned_to = ["kv_su", "st_rw"] }
    (local.entra_users["tviknarajah@bink.com"].object_id) = { assigned_to = ["kv_su", "st_rw"] }
    (local.entra_users["kaziz@bink.com"].object_id)       = { assigned_to = ["kv_ro", "aks_rw"] }
    (local.entra_users["ml@bink.com"].object_id)          = { assigned_to = ["rg", "aks_rw", "st_rw"] }
    (local.entra_users["cl@bink.com"].object_id)          = { assigned_to = ["rg", "aks_rw", "st_rw"] }
    (local.entra_users["fmilani@bink.com"].object_id)     = { assigned_to = ["aks_rw"] }
    (local.entra_users["lhamilton@bink.com"].object_id)   = { assigned_to = ["aks_rw"] }
    (local.entra_users["cgouws@bink.com"].object_id)      = { assigned_to = ["aks_rw"] }
    (local.entra_users["mmorar@bink.com"].object_id)      = { assigned_to = ["la"] }
    (local.entra_users["nodedra@bink.com"].object_id)     = { assigned_to = ["la"] }
    (local.entra_groups["Backend"])                       = { assigned_to = ["la", "pg"] }
    (local.entra_groups["Service"])                       = { assigned_to = ["la", "sftp_rw"] }
  }
  managed_identities = {
    "angelia"        = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "boreas"         = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "bullsquid"      = { assigned_to = ["kv_ro"], namespaces = ["portal"] }
    "carina"         = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "cosmos"         = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "cyclops"        = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "eos"            = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "europa"         = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "event-horizon"  = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "harmonia"       = { assigned_to = ["kv_ro"], namespaces = ["txm"] }
    "hermes"         = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "kiroshi"        = { assigned_to = ["kv_ro"], namespaces = ["devops"] }
    "kratos"         = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "metis"          = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "midas"          = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "styx"           = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "polaris"        = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "snowstorm"      = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "vela"           = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "wasabireporter" = { assigned_to = ["kv_ro"], namespaces = ["devops"] }
    "zephyrus"       = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "prefect"        = { assigned_to = ["kv_ro"], namespaces = ["datawarehouse"] }
  }
  kube = {
    sku_tier                  = "Standard"
    automatic_channel_upgrade = "patch"
    pool_vm_size              = "Standard_D4ads_v5"
    ebpf_enabled              = false
    pool_min_count            = 2
    additional_node_pools = {
      spot = { vm_size = "Standard_D4ads_v5" }
      bpl = {
        node_labels = { "bink.com/workload" = "bpl" }
        node_taints = ["bink.com/workload=bpl:NoSchedule"]
        priority    = "Regular"
      }
      olympus = {
        node_labels = { "bink.com/workload" = "olympus" }
        node_taints = ["bink.com/workload=olympus:NoSchedule"]
        priority    = "Regular"
      }
      txm = {
        vm_size     = "Standard_D4ads_v5"
        max_count   = 20
        node_labels = { "bink.com/workload" = "txm", "kubernetes.azure.com/scalesetpriority" = "spot" }
        node_taints = ["bink.com/workload=txm:NoSchedule", "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
      }
    }
  }
  cloudamqp = {
    enabled = true
    plan    = "bunny-3"
    vpc_id  = module.uksouth_cloudamqp.vpc.id
  }
  storage = {
    sftp_enabled = true
    rules = [
      { name = "bridge", prefix_match = ["bridge"], delete_after_days = 14 },
    ]
  }
  postgres = {
    sku                   = "GP_Standard_D32ds_v4",
    version               = 15
    ha                    = true,
    backup_retention_days = 35
    storage_mb            = 1048576,
    databases = [
      "apistats",
      "asset_register",
      "atlas",
      "bullsquid",
      "carina",
      "eos",
      "europa",
      "hades",
      "harmonia",
      "hermes",
      "hubble",
      "kiroshi",
      "midas",
      "polaris",
      "pontus",
      "postgres",
      "prefect",
      "snowstorm",
      "thanatos",
      "vela",
      "zagreus",
    ]
  }
  redis = {
    enabled  = true
    capacity = 2
    family   = "P"
    sku_name = "Premium"
  }
  tableau = { enabled = true }
}
