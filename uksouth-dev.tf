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
        ipv4 = local.secure_origins
        ipv6 = local.secure_origins_v6
    }
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["kv_su"] }
        (local.aad_user.navya_james) = { assigned_to = ["kv_su"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
        (local.aad_group.architecture) = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
        (local.aad_user.michael_morar) = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
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
    postgres = { core = { entra_id_enabled = true } }
    redis = { enabled = true }
}
