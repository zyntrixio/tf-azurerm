module "uksouth_ait" {
  source = "./cluster"
  providers = {
    azurerm      = azurerm.uksouth_ait
    azurerm.core = azurerm
  }
  common = {
    name     = "ait"
    location = "uksouth"
    cidr     = "10.61.0.0/16"
  }
  firewall = module.uksouth_firewall.peer_info
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
    (local.entra_groups["Backend"])                       = { assigned_to = ["rg", "pg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
    (local.entra_groups["Architecture"])                  = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
  }
  managed_identities = {
    "starbug"   = { assigned_to = ["mi"], namespaces = ["starbug"] } #TODO figure out how to set this without owner permissions
    "angelia"   = { assigned_to = ["kv_ro"], namespaces = [] }
    "boreas"    = { assigned_to = ["kv_ro"], namespaces = [] }
    "bullsquid" = { assigned_to = ["kv_ro"], namespaces = [] }
    "cosmos"    = { assigned_to = ["kv_ro"], namespaces = [] }
    "eos"       = { assigned_to = ["kv_ro"], namespaces = [] }
    "europa"    = { assigned_to = ["kv_ro"], namespaces = [] }
    "harmonia"  = { assigned_to = ["kv_ro"], namespaces = [] }
    "hermes"    = { assigned_to = ["kv_ro"], namespaces = ["configuration"] }
    "kiroshi"   = { assigned_to = ["kv_ro"], namespaces = [] }
    "metis"     = { assigned_to = ["kv_ro"], namespaces = [] }
    "midas"     = { assigned_to = ["kv_ro"], namespaces = [] }
    "snowstorm" = { assigned_to = ["kv_ro"], namespaces = [] }
    "zephyrus"  = { assigned_to = ["kv_ro"], namespaces = [] }
  }
  kube = {
    automatic_channel_upgrade = "patch"
    additional_node_pools     = { starbug = { vm_size = "Standard_D32ads_v5", os_disk_size_gb = 1024 } }
  }
  cloudamqp = { enabled = false }
  storage   = { sftp_enabled = false }
  postgres  = { sku = "B_Standard_B1ms", storage_mb = 32768, databases = ["api_reflector", "europa", "hermes", "postgres"] }
  redis     = { enabled = false }
}
