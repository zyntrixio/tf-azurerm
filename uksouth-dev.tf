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
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw"] }
        (local.aad_group.qa) = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
        (local.aad_group.architecture) = { assigned_to = ["rg", "aks_ro", "kv_ro"] }
    }
    managed_identities = {
        "angelia" = { assigned_to = ["kv_ro"] }
        "boreas" = { assigned_to = ["kv_ro"] }
        "carina" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "cert-manager" = { namespace = "cert-manager" }
        "cosmos" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "eos" = { assigned_to = ["kv_ro"] }
        "europa" = { assigned_to = ["kv_ro"] }
        "event-horizon" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "harmonia" = { assigned_to = ["kv_ro"] }
        "hermes" = { assigned_to = ["kv_ro"] }
        "keyvault2kube" = { assigned_to = ["kv_ro"], namespace = "kube-system" }
        "metis" = { assigned_to = ["kv_ro"] }
        "midas" = { assigned_to = ["kv_ro"] }
        "polaris" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "snowstorm" = { assigned_to = ["kv_ro"] }
        "vela" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "zephyrus" = { assigned_to = ["kv_ro"] }
    }
    kube = {
        enabled = true
        authorized_ip_ranges = local.secure_origins
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
    redis = { enabled = false }
}
