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

    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
    }
    managed_identities = {}

    kube = {
        enabled = false
        authorized_ip_ranges = local.secure_origins
    }
    storage = { enabled = true }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = false }
    redis = { enabled = false }
}
