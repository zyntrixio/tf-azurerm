module "uksouth_staging" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_staging
        azurerm.core = azurerm
    }
    allowed_hosts = {
        ipv4 = local.secure_origins
        ipv6 = local.secure_origins_v6
    }
    common = {
        name = "staging"
        location = "uksouth"
        cidr = "10.31.0.0/16"
    }
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["kv_su"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw"] }
        (local.aad_group.qa) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_ro"] }
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
        "kiroshi" = { assigned_to = ["kv_ro"], namespaces = ["default","devops","bpl"]}
        "metis" = { assigned_to = ["kv_ro"] }
        "midas" = { assigned_to = ["kv_ro"] }
        "polaris" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "pyqa" = { assigned_to = ["kv_ro"] }
        "snowstorm" = { assigned_to = ["kv_ro"] }
        "styx" = { assigned_to = ["kv_ro"] }
        "vela" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "zephyrus" = { assigned_to = ["kv_ro"] }
        "prefect" = { assigned_to = ["kv_ro"], namespaces = ["datawarehouse"] }
    }
    kube = {
        enabled = true
        flux_enabled = true
        authorized_ip_ranges = local.secure_origins
    }
    storage = {
        enabled = true
        rules = [
            { name = "backupshourly", prefix_match = ["backups/hourly"], delete_after_days = 30 },
            { name = "backupsweekly", prefix_match = ["backups/weekly"], delete_after_days = 90 },
            { name = "backupsyearly", prefix_match = ["backups/yearly"], delete_after_days = 1095 },
            { name = "qareports", prefix_match = ["qareports/"], delete_after_days = 30},
        ]
    }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = true }
    redis = { enabled = false }
    tableau = { 
        enabled = true
        size = "Standard_E2ads_v5"
    }
}
