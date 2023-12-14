module "uksouth_ait" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_ait
        azurerm.core = azurerm
    }
    common = {
        name = "ait"
        location = "uksouth"
        cidr = "10.61.0.0/16"
    }
    dns = { id = module.uksouth_dns.bink_sh_id }
    acr = { id = module.uksouth_core.acr_id }
    allowed_hosts = {
        ipv4 = concat(local.secure_origins, [module.uksouth_tailscale.ip_addresses.ipv4_cidr])
        ipv6 = concat(local.secure_origins_v6, [module.uksouth_tailscale.ip_addresses.ipv6_cidr])
    }
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["kv_su"] }
        (local.aad_user.navya_james) = { assigned_to = ["kv_su"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
        (local.aad_group.architecture) = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
    }
    managed_identities = {
        "starbug" = { assigned_to = ["mi"], namespaces = ["starbug"] } #TODO figure out how to set this without owner permissions
        "angelia" = { assigned_to = ["kv_ro"], namespaces = [] }
        "boreas" = { assigned_to = ["kv_ro"], namespaces = [] }
        "bullsquid" = { assigned_to = ["kv_ro"], namespaces = [] }
        "cosmos" = { assigned_to = ["kv_ro"], namespaces = [] }
        "eos" = { assigned_to = ["kv_ro"], namespaces = [] }
        "europa" = { assigned_to = ["kv_ro"], namespaces = [] }
        "harmonia" = { assigned_to = ["kv_ro"], namespaces = [] }
        "hermes" = { assigned_to = ["kv_ro"], namespaces = ["configuration"] }
        "kiroshi" = { assigned_to = ["kv_ro"], namespaces = [] }
        "metis" = { assigned_to = ["kv_ro"], namespaces = [] }
        "midas" = { assigned_to = ["kv_ro"], namespaces = [] }
        "snowstorm" = { assigned_to = ["kv_ro"], namespaces = [] }
        "zephyrus" = { assigned_to = ["kv_ro"], namespaces = [] }
    }
    kube = {
        enabled = true
        automatic_channel_upgrade = "patch"
        additional_node_pools = { starbug = { vm_size = "Standard_D32ads_v5", os_disk_size_gb = 1024 } }
    }
    cloudamqp = { enabled = false }
    storage = {
        enabled = true
        sftp_enabled = false
        nfs_enabled = false
    }
    loganalytics = { enabled = false }
    keyvault = { enabled = true }
    postgres = { core = { sku = "B_Standard_B1ms", storage_mb = 32768 } }
    redis = { enabled = false }
}
