## TODO: Assign Snowstorm identity to Log Analytics automatically.

module "uksouth_prod" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_production
        azurerm.core = azurerm
    }
    common = {
        name = "prod"
        location = "uksouth"
        cidr = "10.11.0.0/16"
    }
    backups = {
        redundancy = "GeoRedundant"
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
        (local.aad_user.mick_latham) = { assigned_to = ["rg", "aks_rw", "st_rw"] }
        (local.aad_group.backend) = { assigned_to = ["la"] }
        (local.aad_user.michael_morar) = { assigned_to = ["la"] }
        (local.aad_user.navin_odedra) = { assigned_to = ["la"] }
        (local.aad_group.service) = { assigned_to = ["la"] }
    }
    managed_identities = {
        "angelia" = { assigned_to = ["kv_ro"] }
        "boreas" = { assigned_to = ["kv_ro"] }
        "bullsquid" = { assigned_to = ["kv_ro"], namespaces = ["portal"] }
        "carina" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "cosmos" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "cyclops" = { assigned_to = ["kv_ro"] }
        "eos" = { assigned_to = ["kv_ro"] }
        "europa" = { assigned_to = ["kv_ro"] }
        "event-horizon" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "harmonia" = { assigned_to = ["kv_ro"] }
        "hermes" = { assigned_to = ["kv_ro"] }
        "kiroshi" = { assigned_to = ["kv_ro"], namespaces = ["devops"] }
        "kratos" = { assigned_to = ["kv_ro"] }
        "metis" = { assigned_to = ["kv_ro"] }
        "midas" = { assigned_to = ["kv_ro"] }
        "styx" = { assigned_to = ["kv_ro"] }
        "polaris" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "snowstorm" = { assigned_to = ["kv_ro"] }
        "vela" = { assigned_to = ["kv_ro"], namespaces = ["bpl"] }
        "wasabireporter" = { assigned_to = ["kv_ro"], namespaces = ["devops"] }
        "zephyrus" = { assigned_to = ["kv_ro"] }
        "prefect" = { assigned_to = ["kv_ro"], namespaces = ["datawarehouse"] }
    }
    kube = {
        enabled = true
        sku_tier = "Standard"
        automatic_channel_upgrade = "patch"
        authorized_ip_ranges = local.secure_origins
        additional_node_pools = { spot = {} }
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
        rules = [
            { name = "bridge", prefix_match = ["bridge"], delete_after_days = 14 },
            { name = "backupshourly", prefix_match = ["backups/hourly"], delete_after_days = 30 },
            { name = "backupsweekly", prefix_match = ["backups/weekly"], delete_after_days = 90 },
            { name = "backupsyearly", prefix_match = ["backups/yearly"], delete_after_days = 1095 },
        ]
    }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = {
        enabled = true,
        sku = "GP_Standard_D8ds_v4",
        version = 15
        ha = true,
        backup_retention_days = 35
        storage_mb = 1048576,
        extra_databases = ["asset_register"],
    }
    redis = {
        enabled = true
        capacity = 1
        family = "P"
        sku_name = "Premium"
    }
    tableau = { enabled = true }
}
