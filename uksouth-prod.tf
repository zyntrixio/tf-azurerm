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
    iam = {
        (local.aad_user.chris_pressland) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.nathan_read) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.thenuja_viknarajah) = { assigned_to = ["st_rw", "kv_su"] }
        (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
        (local.aad_user.mick_latham) = { assigned_to = ["rg", "aks_rw"] }
    }
    managed_identities = {
        "angelia" = { assigned_to = ["kv_ro"] }
        "boreas" = { assigned_to = ["kv_ro"] }
        "carina" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "cert-manager" = { namespace = "cert-manager" }
        "cosmos" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "cyclops" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "eos" = { assigned_to = ["kv_ro"] }
        "europa" = { assigned_to = ["kv_ro"] }
        "event-horizon" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "harmonia" = { assigned_to = ["kv_ro"] }
        "hermes" = { assigned_to = ["kv_ro"] }
        "keyvault2kube" = { assigned_to = ["kv_ro"], namespace = "kube-system" }
        "kiroshi" = { namespace = "devops" }
        "kratos" = { assigned_to = ["kv_ro"] }
        "metis" = { assigned_to = ["kv_ro"] }
        "midas" = { assigned_to = ["kv_ro"] }
        "styx" = { assigned_to = ["kv_ro"] }
        "polaris" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "snowstorm" = { assigned_to = ["kv_ro"] }
        "vela" = { assigned_to = ["kv_ro"], namespace = "bpl" }
        "wasabireporter" = { assigned_to = ["kv_ro"], namespace = "devops" }
        "zephyrus" = { assigned_to = ["kv_ro"] }
    }
    kube = {
        enabled = true
        sku_tier = "Standard"
        automatic_channel_upgrade = "patch"
        authorized_ip_ranges = local.secure_origins
        additional_node_pools = {
            "rabbitmq" = { node_count = 3, node_taints = ["app=rabbitmq:NoSchedule"] }
        }
    }
    storage = {
        enabled = true
        rules = [
            { name = "bridge", prefix_match = ["bridge"], delete_after_days = 14 },
            { name = "backupshourly", prefix_match = ["backups/hourly"], delete_after_days = 30 },
            { name = "backupsweekly", prefix_match = ["backups/weekly"], delete_after_days = 90 },
            { name = "backupsyearly", prefix_match = ["backups/yearly"], delete_after_days = 1095 },
        ]
    }
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = true, sku = "GP_Standard_D8ds_v4" , ha = true, storage_mb = 1048576 }
    redis = { enabled = true }
    tableau = { enabled = true }
}

module "uksouth_prod_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.19.0"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }
    resource_group_name = "uksouth-prod"
    location = "uksouth"
    tags = {
        "Environment" = "Production",
    }

    vnet_cidr = "192.168.100.0/24"

    loganalytics_id = module.uksouth_loganalytics.id

    postgres_iam = {}
    keyvault_iam = {}
    storage_iam = {}
    redis_iam = {}
    keyvault_users = {}

    postgres_flexible_config = {}

    redis_config = {}
    redis_patch_schedule = {
        day_of_week    = "Wednesday"
        start_hour_utc = 1
    }
    storage_config = {
        common = {
            name = "binkuksouthprod",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
    storage_management_policy_config = {}
    bink_sh_zone_id = module.uksouth-dns.dns_zones.bink_sh.root.id
    bink_host_zone_id = module.uksouth-dns.dns_zones.bink_host.public.id

    managed_identities = merge()
    managed_identities_loganalytics = {}

    aks = {}
}

module "uksouth_prod_datawarehouse" {
    source = "./uksouth/datawarehouse"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }
    common = {
        environment = "prod"
        location = "uksouth"
        cidr = local.cidrs.uksouth.datawarehouse.prod
        private_dns = local.private_dns.prod_defaults
        loganalytics_id = module.uksouth_loganalytics.id
        firewall_ip = module.uksouth_firewall.firewall_ip
        postgres_dns = module.uksouth_prod_environment.postgres_flexible_server_dns_link
        vms = {
            airbyte = { size = "Standard_D2as_v5" }
            prefect = { size = "Standard_D2as_v5" }
        }
        peering = {
            firewall = {
                vnet_id = module.uksouth_firewall.peering.vnet_id
                vnet_name = module.uksouth_firewall.peering.vnet_name
                resource_group = module.uksouth_firewall.peering.rg_name
            }
            environment = {
                vnet_id = module.uksouth_prod_environment.peering.vnet_id
                vnet_name = module.uksouth_prod_environment.peering.vnet_name
                resource_group = module.uksouth_prod_environment.peering.resource_group_name
            }
        }
    }
}
