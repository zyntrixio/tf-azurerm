module "uksouth_dev" {
  source = "./cluster"
  providers = {
    azurerm      = azurerm.uksouth_development
    azurerm.core = azurerm
  }
  common = {
    name     = "dev"
    location = "uksouth"
    cidr     = "10.41.0.0/16"
  }
  backups = {
    resource_id  = module.uksouth_backups.resource_id
    principal_id = module.uksouth_backups.principal_id
    policies     = module.uksouth_backups.policies
  }
  dns = { id = module.uksouth_dns.bink_sh_id }
  acr = { id = module.uksouth_core.acr_id }
  allowed_hosts = {
    ipv4 = concat(local.secure_origins, [module.uksouth_tailscale.ip_addresses.ipv4_cidr])
    ipv6 = concat(local.secure_origins_v6, [module.uksouth_tailscale.ip_addresses.ipv6_cidr])
  }
  iam = {
    (local.aad_user.terraform)                            = { assigned_to = ["kv_su"] }
    (local.entra_users["cpressland@bink.com"].object_id)  = { assigned_to = ["kv_su"] }
    (local.entra_users["nread@bink.com"].object_id)       = { assigned_to = ["kv_su"] }
    (local.entra_users["tviknarajah@bink.com"].object_id) = { assigned_to = ["kv_su"] }
    (local.entra_users["njames@bink.com"].object_id)      = { assigned_to = ["kv_su"] }
    (local.entra_users["mmorar@bink.com"].object_id)      = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
    (local.entra_groups["Backend"])                       = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
    (local.entra_groups["Architecture"])                  = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
  }
  managed_identities = {
    "angelia"       = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
    "boreas"        = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
    "bullsquid"     = { assigned_to = ["kv_ro"], namespaces = ["portal"] }
    "carina"        = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "cosmos"        = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "eos"           = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
    "europa"        = { assigned_to = ["kv_rw"], namespaces = ["default", "olympus"] }
    "event-horizon" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "harmonia"      = { assigned_to = ["kv_ro"], namespaces = ["default", "txm"] }
    "hermes"        = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
    "metis"         = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
    "midas"         = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
    "polaris"       = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "snowstorm"     = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
    "vela"          = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
    "zephyrus"      = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
  }
  kube = { additional_node_pools = { spot = {} } }
  cloudamqp = {
    enabled = true
    vpc_id  = module.uksouth_cloudamqp.vpc.id
  }
  storage = {
    sftp_enabled = false
  }
  postgres = {
    entra_id_admins = [
      local.entra_users["cpressland@bink.com"],
      local.entra_users["nread@bink.com"],
    ]
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
  redis = { enabled = true }
}
