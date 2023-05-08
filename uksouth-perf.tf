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
    managed_identities = {
        "cert-manager" = { namespace = "cert-manager" }
        "keyvault2kube" = { assigned_to = ["kv_ro"], namespace = "kube-system" }
        "locust" = { assigned_to = ["kv_ro"], namespace = "olympus" }
        "angelia" = { assigned_to = ["kv_ro"], namespace = "olympus" }
        "europa" = { assigned_to = ["kv_ro"], namespace = "olympus" }
        "hermes" = { assigned_to = ["kv_ro"], namespace = "olympus" }
        "midas" = { assigned_to = ["kv_ro"], namespace = "olympus" }
    }
    kube = {
        enabled = true
        sku_tier = "Standard"
        authorized_ip_ranges = local.secure_origins
        additional_node_pools = {
            "rabbitmq" = { node_count = 3, node_taints = ["app=rabbitmq:NoSchedule"] }
        }
    }
    storage = { enabled = true }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = {
        enabled = true,
        sku = "GP_Standard_D8ds_v4",
        storage_mb = 1048576,
    }
    redis = { enabled = true }
}
