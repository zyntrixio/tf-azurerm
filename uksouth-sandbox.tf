locals {
    sandbox_common = {
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
            "angelia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "europa" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "harmonia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "hermes" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "metis" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "midas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "boreas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        }
        kube = {
            enabled = true
            authorized_ip_ranges = local.secure_origins,
            # pool_vm_size = "Standard_B4ms"
            pool_os_disk_size_gb = 32
        }
        cloudamqp = {
            enabled = true
            vpc_id = module.uksouth_cloudamqp.vpc.id
        }
        redis = { enabled = true }
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
    }
}

module "uksouth_sandbox" {
    source = "./cluster"
    providers = { azurerm = azurerm.uksouth_sandbox, azurerm.core = azurerm }
    common = { name = "sandbox", location = "uksouth", cidr = "10.20.0.0/16" }
    dns = { id = module.uksouth_dns.bink_sh_id }
    allowed_hosts = local.sandbox_common.allowed_hosts
    iam = local.sandbox_common.iam
    managed_identities = local.sandbox_common.managed_identities
    kube = { enabled = true, authorized_ip_ranges = local.secure_origins }
    cloudamqp = { enabled = true, vpc_id = module.uksouth_cloudamqp.vpc.id }
    storage = { enabled = false, nfs_enabled = false, sftp_enabled = false }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = false }
    redis = { enabled = false }
}

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
    allowed_hosts = local.sandbox_common.allowed_hosts
    iam = local.sandbox_common.iam
    managed_identities = local.sandbox_common.managed_identities
    kube = local.sandbox_common.kube
    cloudamqp = local.sandbox_common.cloudamqp
    storage = local.sandbox_common.storage
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = true, sku = "B_Standard_B1ms", storage_mb = 32768 }
    redis = local.sandbox_common.redis
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
    allowed_hosts = local.sandbox_common.allowed_hosts
    iam = local.sandbox_common.iam
    managed_identities = local.sandbox_common.managed_identities
    kube = local.sandbox_common.kube
    cloudamqp = local.sandbox_common.cloudamqp
    storage = local.sandbox_common.storage
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = true, sku = "B_Standard_B1ms", storage_mb = 32768 }
    redis = local.sandbox_common.redis
}
