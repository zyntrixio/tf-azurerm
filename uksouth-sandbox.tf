module "uksouth_sandbox" {
    source = "./cluster"
    providers = { azurerm = azurerm.uksouth_sandbox, azurerm.core = azurerm }
    common = { name = "sandbox", location = "uksouth", cidr = "10.20.0.0/16" }
    dns = { id = module.uksouth_dns.bink_sh_id }
    acr = { id = module.uksouth_core.acr_id }
    allowed_hosts = { ipv4 = local.secure_origins, ipv6 = local.secure_origins_v6 }
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["kv_su"] }
        (local.aad_user.navya_james) = { assigned_to = ["kv_su"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
        (local.aad_group.architecture) = { assigned_to = ["rg", "aks_rw", "kv_rw"] }
    }
    managed_identities = {
        "boreas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    }
    kube = { enabled = true, additional_node_pools = { spot = { } } }
    cloudamqp = { enabled = true, vpc_id = module.uksouth_cloudamqp.vpc.id }
    storage = { enabled = false, nfs_enabled = false, sftp_enabled = false }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = {
        lloyds = { sku = "B_Standard_B1ms", storage_mb = 32768 }
        retail = { sku = "B_Standard_B1ms", storage_mb = 32768 }
    }
    redis = { enabled = false }
}

## Legacy Sandboxes

module "uksouth_retail" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_sandbox
        azurerm.core = azurerm
    }
    common = {
        name = "retail"
        location = "uksouth"
        cidr = "10.21.0.0/16"
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
    }
    managed_identities = {
        "angelia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "boreas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "europa" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "harmonia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "hermes" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "metis" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "midas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    }
    kube = {
        enabled = true
        additional_node_pools = { spot = { } }
        ebpf_enabled = false
    }
    cloudamqp = {
        enabled = true
        vpc_id = module.uksouth_cloudamqp.vpc.id
    }
    storage = {
        enabled = true
        nfs_enabled = true
        sftp_enabled = false
        rules = [
            { name = "backupshourly", prefix_match = ["backups/hourly"], delete_after_days = 30 },
            { name = "backupsweekly", prefix_match = ["backups/weekly"], delete_after_days = 90 },
            { name = "backupsyearly", prefix_match = ["backups/yearly"], delete_after_days = 1095 },
        ]
    }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { core = { sku = "B_Standard_B1ms", storage_mb = 32768 } }
    redis = { enabled = true }
}

module "uksouth_lloyds" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_sandbox
        azurerm.core = azurerm
    }
    common = {
        name = "lloyds"
        location = "uksouth"
        cidr = "10.23.0.0/16"
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
    }
    managed_identities = {
        "angelia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "boreas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "europa" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "harmonia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "hermes" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "metis" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "midas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    }
    kube = {
        enabled = true
        additional_node_pools = { spot = { } }
        ebpf_enabled = false
    }
    cloudamqp = {
        enabled = true
        vpc_id = module.uksouth_cloudamqp.vpc.id
    }
    storage = {
        enabled = true
        nfs_enabled = true
        sftp_enabled = false
        rules = [
            { name = "backupshourly", prefix_match = ["backups/hourly"], delete_after_days = 30 },
            { name = "backupsweekly", prefix_match = ["backups/weekly"], delete_after_days = 90 },
            { name = "backupsyearly", prefix_match = ["backups/yearly"], delete_after_days = 1095 },
        ]
    }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { core = { sku = "B_Standard_B1ms", storage_mb = 32768 } }
    redis = { enabled = true }
}
