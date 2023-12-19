module "uksouth_dev" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_development
        azurerm.core = azurerm
    }
    common = {
        name = "dev"
        location = "uksouth"
        cidr = "10.41.0.0/16"
    }
    dns = { id = module.uksouth_dns.bink_sh_id }
    acr = { id = module.uksouth_core.acr_id }
    allowed_hosts = {
        ipv4 = concat(local.secure_origins, [module.uksouth_tailscale.ip_addresses.ipv4_cidr])
        ipv6 = concat(local.secure_origins_v6, [module.uksouth_tailscale.ip_addresses.ipv6_cidr])
    }
    iam = {
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.entra_users["cpressland@bink.com"].object_id) = { assigned_to = ["kv_su"] }
        (local.entra_users["nread@bink.com"].object_id) = { assigned_to = ["kv_su"] }
        (local.entra_users["tviknarajah@bink.com"].object_id) = { assigned_to = ["kv_su"] }
        (local.entra_users["njames@bink.com"].object_id) = { assigned_to = ["kv_su"] }
        (local.entra_users["mmorar@bink.com"].object_id) = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
        (local.entra_groups["Backend"]) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
        (local.entra_groups["Architecture"]) = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
        (local.entra_users["jirving@bink.com"].object_id) = { assigned_to = ["aks_ro"] }
    }
    managed_identities = {
        "angelia" = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
        "boreas" = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
        "bullsquid" = { assigned_to = ["kv_ro"], namespaces = ["portal"] }
        "carina" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "cosmos" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "eos" = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
        "europa" = { assigned_to = ["kv_rw"], namespaces = ["default", "olympus"] }
        "event-horizon" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "harmonia" = { assigned_to = ["kv_ro"], namespaces = ["default", "txm"] }
        "hermes" = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
        "metis" = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
        "midas" = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
        "polaris" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "snowstorm" = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
        "vela" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "zephyrus" = { assigned_to = ["kv_ro"], namespaces = ["default", "olympus"] }
    }
    kube = { enabled = true, additional_node_pools = { spot = { } } }
    cloudamqp = {
        enabled = true
        vpc_id = module.uksouth_cloudamqp.vpc.id
    }
    storage = {
        enabled = true
        sftp_enabled = true
        nfs_enabled = true
        rules = [
            { name = "backupshourly", prefix_match = ["backups/hourly"], delete_after_days = 30 },
            { name = "backupsweekly", prefix_match = ["backups/weekly"], delete_after_days = 90 },
            { name = "backupsyearly", prefix_match = ["backups/yearly"], delete_after_days = 1095 },
        ]
    }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { core = {
        entra_id_admins = [
            local.entra_users["cpressland@bink.com"],
            local.entra_users["nread@bink.com"],
        ]
    } }
    redis = { enabled = true }
}
