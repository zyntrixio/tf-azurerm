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
    allowed_hosts = {
        ipv4 = local.secure_origins
        ipv6 = local.secure_origins_v6
    }
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["kv_su"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw"] }
        (local.aad_group.qa) = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
        (local.aad_group.architecture) = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
    }
    managed_identities = {
        "angelia" = { assigned_to = ["kv_ro"] }
        "boreas" = { assigned_to = ["kv_ro"] }
        "bullsquid" = { assigned_to = ["kv_ro"], namespaces = ["portal"] }
        "carina" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "cert-manager" = { namespaces = ["cert-manager"] }
        "cosmos" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "eos" = { assigned_to = ["kv_ro"] }
        "europa" = { assigned_to = ["kv_rw"] }
        "event-horizon" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "harmonia" = { assigned_to = ["kv_ro"] }
        "hermes" = { assigned_to = ["kv_ro"] }
        "keyvault2kube" = { assigned_to = ["kv_ro"], namespaces = ["kube-system"] }
        "metis" = { assigned_to = ["kv_ro"] }
        "midas" = { assigned_to = ["kv_ro"] }
        "polaris" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "snowstorm" = { assigned_to = ["kv_ro"] }
        "vela" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "zephyrus" = { assigned_to = ["kv_ro"] }
    }
    kube = {
        enabled = true
        authorized_ip_ranges = local.secure_origins
    }
    cloudamqp = {
        enabled = true
        vpc_id = module.uksouth_cloudamqp.vpc.id
    }
    storage = {
        enabled = true
        rules = [
            { name = "backupshourly", prefix_match = ["backups/hourly"], delete_after_days = 30 },
            { name = "backupsweekly", prefix_match = ["backups/weekly"], delete_after_days = 90 },
            { name = "backupsyearly", prefix_match = ["backups/yearly"], delete_after_days = 1095 },
        ]
    }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = true }
    redis = {
        enabled = true
        capacity = 0
        family = "C"
        sku_name = "Basic"
    }
}
