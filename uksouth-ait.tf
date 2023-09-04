module "uksouth_ait" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_ait
        azurerm.core = azurerm
    }
    common = {
        name = "ait"
        location = "uksouth"
        cidr = "10.61.0.0/16"
    }
    allowed_hosts = {
        ipv4 = local.secure_origins
        ipv6 = local.secure_origins_v6
    }
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["kv_su"] }
        (local.aad_user.navya_james) = { assigned_to = ["aks_rw"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw", "ac_rw"] }
        (local.aad_group.architecture) = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
    }
    managed_identities = {
        "cert-manager" = { namespaces = ["cert-manager"] }
        "keyvault2kube" = { assigned_to = ["kv_ro"], namespaces = ["kube-system"] }
    }
    kube = {
        enabled = true
        authorized_ip_ranges = local.secure_origins
        additional_node_pools = {
            starbug = {
                vm_size = "Standard_E32ads_v5"
                enable_auto_scaling = true
                min_count = 0
                max_count = 3
                priority = "Spot"
                node_labels = {"kubernetes.azure.com/scalesetpriority" = "spot"}
                node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
            }
        }
    }
    cloudamqp = { enabled = false }
    storage = {
        enabled = true
        sftp_enabled = false
        nfs_enabled = false
    }
    loganalytics = { enabled = false }
    keyvault = { enabled = true }
    postgres = { enabled = false }
    redis = { enabled = false }
}
