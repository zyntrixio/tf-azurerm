## Legacy Sandboxes

module "uksouth_retail" {
  source = "./cluster"
  providers = {
    azurerm      = azurerm.uksouth_sandbox
    azurerm.core = azurerm
  }
  common = {
    name     = "retail"
    location = "uksouth"
    cidr     = "10.21.0.0/16"
  }
  backups = {
    resource_id  = module.uksouth_backups.resource_id
    principal_id = module.uksouth_backups.principal_id
    policies     = module.uksouth_backups.policies
  }
  dns = { id = module.uksouth_dns.bink_sh_id }
  acr = { id = module.uksouth_core.acr_id }
  allowed_hosts = {
    ipv4 = concat(local.secure_origins)
    ipv6 = concat(local.secure_origins_v6)
  }
  iam = {
    (local.aad_user.terraform)                            = { assigned_to = ["kv_su"] }
    (local.entra_users["cpressland@bink.com"].object_id)  = { assigned_to = ["kv_su"] }
    (local.entra_users["nread@bink.com"].object_id)       = { assigned_to = ["kv_su"] }
    (local.entra_users["tviknarajah@bink.com"].object_id) = { assigned_to = ["kv_su"] }
    (local.entra_users["njames@bink.com"].object_id)      = { assigned_to = ["kv_su"] }
    (local.entra_groups["Backend"])                       = { assigned_to = ["rg", "pg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
    (local.entra_groups["Architecture"])                  = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
  }
  managed_identities = {
    "angelia"  = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "boreas"   = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "europa"   = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "harmonia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "hermes"   = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "metis"    = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "midas"    = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
  }
  kube = {
    additional_node_pools = { spot = {} }
    ebpf_enabled          = false
  }
  cloudamqp = {
    enabled = true
    vpc_id  = module.uksouth_cloudamqp.vpc.id
  }
  storage = { sftp_enabled = false }
  postgres = {
    sku        = "B_Standard_B1ms",
    storage_mb = 32768,
    databases = [
      "api_reflector",
      "atlas",
      "europa",
      "hades",
      "hermes",
      "midas",
      "postgres",
      "snowstorm",
    ]
  }
  redis = { enabled = true }
}

module "uksouth_lloyds" {
  source = "./cluster"
  providers = {
    azurerm      = azurerm.uksouth_sandbox
    azurerm.core = azurerm
  }
  common = {
    name     = "lloyds"
    location = "uksouth"
    cidr     = "10.23.0.0/16"
  }
  backups = {
    resource_id  = module.uksouth_backups.resource_id
    principal_id = module.uksouth_backups.principal_id
    policies     = module.uksouth_backups.policies
  }
  dns = { id = module.uksouth_dns.bink_sh_id }
  acr = { id = module.uksouth_core.acr_id }
  allowed_hosts = {
    ipv4 = concat(local.secure_origins)
    ipv6 = concat(local.secure_origins_v6)
  }
  iam = {
    (local.aad_user.terraform)                            = { assigned_to = ["kv_su"] }
    (local.entra_users["cpressland@bink.com"].object_id)  = { assigned_to = ["kv_su"] }
    (local.entra_users["nread@bink.com"].object_id)       = { assigned_to = ["kv_su"] }
    (local.entra_users["tviknarajah@bink.com"].object_id) = { assigned_to = ["kv_su"] }
    (local.entra_users["njames@bink.com"].object_id)      = { assigned_to = ["kv_su"] }
    (local.entra_groups["Backend"])                       = { assigned_to = ["rg", "pg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
    (local.entra_groups["Architecture"])                  = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
  }
  managed_identities = {
    "angelia"  = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "boreas"   = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "europa"   = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "harmonia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "hermes"   = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "metis"    = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    "midas"    = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
  }
  kube = {
    additional_node_pools = { spot = {} }
    ebpf_enabled          = false
  }
  cloudamqp = {
    enabled = true
    vpc_id  = module.uksouth_cloudamqp.vpc.id
  }
  storage = { sftp_enabled = false }
  postgres = {
    sku        = "B_Standard_B1ms",
    storage_mb = 32768
    databases = [
      "api_reflector",
      "atlas",
      "europa",
      "hades",
      "hermes",
      "midas",
      "postgres",
      "snowstorm",
      "kiroshi",
    ]
  }
  redis = { enabled = true }
}
