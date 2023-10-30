module "uksouth_perf" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_performance
        azurerm.core = azurerm
    }
    common = {
        name = "perf"
        location = "uksouth"
        cidr = "10.51.0.0/16"
    }
    allowed_hosts = {
        ipv4 = local.secure_origins
        ipv6 = local.secure_origins_v6
    }
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["kv_su"] }
        (local.aad_user.navya_james) = { assigned_to = ["aks_rw", "st_rw"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
        (local.aad_group.architecture) = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
    }
    managed_identities = {
        "cert-manager" = { namespaces = ["cert-manager"] }
        "keyvault2kube" = { assigned_to = ["kv_ro"], namespaces = ["kube-system"] }
        "locust" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "angelia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "boreas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "europa" = { assigned_to = ["kv_rw"], namespaces = ["olympus"] }
        "hermes" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "midas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "metis" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "harmonia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "zephyrus" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        "atalanta" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
    }
    kube = {
        enabled = true
        sku_tier = "Standard"
        authorized_ip_ranges = local.secure_origins
    }
    cloudamqp = {
        enabled = true
        plan = "bunny-3"
        vpc_id = module.uksouth_cloudamqp.vpc.id
    }
    storage = {
        enabled = true
        sftp_enabled = true
        nfs_enabled = true
    }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = {
        enabled = true,
        sku = "GP_Standard_D8ds_v4",
        storage_mb = 1048576,
    }
    redis = {
        enabled = true
        capacity = 1
        family = "P"
        sku_name = "Premium"
    }
}
