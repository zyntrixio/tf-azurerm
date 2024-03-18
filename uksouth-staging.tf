module "uksouth_staging" {
  source = "./cluster"
  providers = {
    azurerm      = azurerm.uksouth_staging
    azurerm.core = azurerm
  }
  common = {
    name     = "staging"
    location = "uksouth"
    cidr     = "10.31.0.0/16"
  }
  frontdoor = {
    profile = module.uksouth_frontdoor.profile
    domains = {
      "api.staging.gb.bink.com" = {
        origin_fqdn = "api.staging.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-staging-gb-bink-com"]
      }
      "bpl.staging.gb.bink.com" = {
        origin_fqdn = "bpl.staging.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-staging-gb-bink-com"]
      }
      "rewards.staging.gb.bink.com" = {
        origin_fqdn = "rewards.staging.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-staging-gb-bink-com"]
      }
      "policies.staging.gb.bink.com" = {
        origin_fqdn = "policies.staging.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-staging-gb-bink-com"]
      }
      "docs.staging.gb.bink.com" = {
        origin_fqdn = "docs.staging.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-staging-gb-bink-com"]
      }
      "portal.staging.gb.bink.com" = {
        origin_fqdn = "portal.staging.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-staging-gb-bink-com"]
      }
      "retailer.staging.gb.bink.com" = {
        origin_fqdn = "retailer.staging.uksouth.bink.sh"
        certificate = module.uksouth_frontdoor.certificates["acmebot-staging-gb-bink-com"]
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
    (local.entra_users["mmorar@bink.com"].object_id)      = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
    (local.entra_groups["Backend"])                       = { assigned_to = ["rg", "pg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
    (local.entra_groups["Architecture"])                  = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
    (local.entra_groups["Business Analysis"])             = { assigned_to = ["st_rw", "la"] }
    (local.entra_groups["Data Engineers"])                = { assigned_to = ["st_ro"] }
    (local.entra_groups["Service"])                       = { assigned_to = ["sftp_ro"] }
  }
  managed_identities = {
    "airbyte"       = { assigned_to = ["kv_ro"], namespaces = ["datawarehouse"] }
    "angelia"       = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "boreas"        = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "bullsquid"     = { assigned_to = ["kv_ro"], namespaces = ["portal"] }
    "carina"        = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "cosmos"        = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "eos"           = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "europa"        = { assigned_to = ["kv_rw"], namespaces = ["olympus"] }
    "event-horizon" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "harmonia"      = { assigned_to = ["kv_ro"], namespaces = ["txm"] }
    "hermes"        = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "kiroshi"       = { assigned_to = ["kv_ro"], namespaces = ["devops", "bpl", "olympus"] }
    "metis"         = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "midas"         = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "polaris"       = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "pyqa"          = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "snowstorm"     = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "styx"          = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "vela"          = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "zephyrus"      = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "prefect"       = { assigned_to = ["kv_ro"], namespaces = ["datawarehouse", "airbyte"] }
  }
  kube = { additional_node_pools = { spot = {} } }
  cloudamqp = {
    enabled = true
    vpc_id  = module.uksouth_cloudamqp.vpc.id
  }
  storage = {
    sftp_enabled = true
    rules = [
      { name = "qareports", prefix_match = ["qareports/"], delete_after_days = 30 },
    ]
  }
  postgres = {
    databases = [
      "airbyte",
      "api_reflector",
      "atlas",
      "carina",
      "cosmos",
      "eos",
      "europa",
      "hades",
      "harmonia",
      "helios",
      "hermes",
      "kiroshi",
      "midas",
      "polaris",
      "pontus",
      "postgres",
      "prefect",
      "snowstorm",
      "vela",
      "zagreus",
    ]
  }
  redis   = { enabled = true }
  tableau = { enabled = false }
}
