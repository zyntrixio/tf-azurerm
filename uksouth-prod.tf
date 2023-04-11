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
    }
    managed_identities = {
        "angelia" = { assigned_to = ["kv_ro"] }
        "boreas" = { assigned_to = ["kv_ro"] }
        "carina" = { assigned_to = ["kv_ro"] }
        "cert-manager" = { assigned_to = [] }
        "cosmos" = { assigned_to = ["kv_ro"] }
        "eos" = { assigned_to = ["kv_ro"] }
        "europa" = { assigned_to = ["kv_ro"] }
        "event-horizon" = { assigned_to = ["kv_ro"] }
        "harmonia" = { assigned_to = ["kv_ro"] }
        "hermes" = { assigned_to = ["kv_ro"] }
        "keyvault2kube" = { assigned_to = ["kv_ro"] }
        "metis" = { assigned_to = ["kv_ro"] }
        "midas" = { assigned_to = ["kv_ro"] }
        "polaris" = { assigned_to = ["kv_ro"] }
        "snowstorm" = { assigned_to = ["kv_ro"] }
        "vela" = { assigned_to = ["kv_ro"] }
        "zephyrus" = { assigned_to = ["kv_ro"] }
    }
    kube = {
        enabled = true
        sku_tier = "Standard"
        automatic_channel_upgrade = "patch"
        flux_enabled = false
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
    postgres = { enabled = false }
    redis = { enabled = false }
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

    postgres_iam = {
        ChrisLatham = {
            object_id = local.aad_user.chris_latham,
            role = "Reader",
        }
    }

    keyvault_iam = {
        MickLatham = {
            object_id = local.aad_user.mick_latham,
            role = "Reader",
        },
        chris_latham = {
            object_id = local.aad_user.chris_latham,
            role = "Reader",
        },
        qa = {
            object_id = local.aad_group.qa,
            role = "Reader",
        },
    }

    storage_iam = {
        mick_latham = {
            storage_id = "common",
            object_id = local.aad_user.mick_latham,
            role = "Contributor",
        },
        chris_latham = {
            storage_id = "common",
            object_id = local.aad_user.chris_latham,
            role = "Contributor",
        },
    }

    redis_iam = {
        chris_latham = {
            object_id = local.aad_user.chris_latham,
            role = "Reader",
        }
    }

    keyvault_users = {
        mick_latham = local.aad_user.mick_latham,
        chris_latham = local.aad_user.chris_latham,
    }

    postgres_flexible_config = {
        common = {
            name = "bink-uksouth-prod"
            version = "13"
            sku_name = "GP_Standard_D8ds_v4"
            storage_mb = 1048576
            high_availability = true
            databases = [
                "atlas",
                "eos",
                "europa",
                "hades",
                "harmonia",
                "hermes",
                "midas",
                "pontus",
                "postgres",
                "zagreus",
                "carina",
                "polaris",
                "vela",
                "snowstorm",
            ]
        },
        tableau = {
            name = "bink-uksouth-tableau"
            version = "13"
            sku_name = "GP_Standard_D4ds_v4"
            storage_mb = 1048576
            high_availability = false
            databases = [
                "postgres",
            ]
        },
    }

    redis_config = {
        vnet = { name = "bink-uksouth-prod" }
    }
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
    storage_management_policy_config = {
        common = [
            {
                name = "backupshourly",
                enabled = true,
                prefix_match = ["backups/hourly"],
                delete_after_days = 30
            },
            {
                name = "backupsweekly",
                enabled = true,
                prefix_match = ["backups/weekly"],
                delete_after_days = 180
            },
            {
                name = "backupsyearly",
                enabled = true,
                prefix_match = ["backups/yearly"],
                delete_after_days = 1095
            },
            {
                name = "bridge",
                enabled = true,
                prefix_match = ["bridge"],
                delete_after_days = 14
            },
            {
                name = "data-management",
                enabled = true,
                prefix_match = ["data-management"],
                delete_after_days = 1
            },
        ]
    }
    bink_sh_zone_id = module.uksouth-dns.dns_zones.bink_sh.root.id
    bink_host_zone_id = module.uksouth-dns.dns_zones.bink_host.public.id

    managed_identities = merge(
        local.managed_identities, {
            wasabireport = { kv_access = "ro" },
            kratos = { kv_access = "ro" },
    })
    managed_identities_loganalytics = {
        tableau = { role = "Reader" }
    }

    aks = {
        prod0 = merge(local.aks_config_defaults_prod, {
            name = "prod0"
            cidr = local.cidrs.uksouth.aks.prod0
            dns = local.aks_dns.prod_defaults
            api_ip_ranges = concat(local.secure_origins, [module.uksouth_firewall.public_ip_prefix])
            iam = merge(local.aks_iam_production, {})
            firewall = merge(local.aks_firewall_defaults, {rule_priority = 1100})
        })
    }
}

module "uksouth_prod_tableau" {
    source = "./uksouth/tableau"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }

    firewall = {
        vnet_id = module.uksouth_firewall.vnet_id,
        vnet_name = module.uksouth_firewall.vnet_name,
        resource_group_name = module.uksouth_firewall.resource_group_name,
    }
    environment = {
        vnet_id = module.uksouth_prod_environment.peering.vnet_id
        vnet_name = module.uksouth_prod_environment.peering.vnet_name
        resource_group_name = module.uksouth_prod_environment.peering.resource_group_name
    }
    postgres_flexible_server_dns_link = module.uksouth_prod_environment.postgres_flexible_server_dns_link
    loganalytics_id = module.uksouth_loganalytics.id
    private_dns = local.private_dns.prod_defaults
    ip_range = local.cidrs.uksouth.tableau
}

module "uksouth_prod_amqp" {
    source = "./uksouth/amqp"
    providers = {
        azurerm = azurerm.uk_production
        azurerm.core = azurerm
    }
    common = {
        environment = "prod"
        cidr = local.cidrs.uksouth.amqp.prod
        loganalytics_id = module.uksouth_loganalytics.id
        private_dns = local.private_dns.prod_defaults
        client_cidrs = [ local.cidrs.uksouth.aks.prod0, local.cidrs.uksouth.aks.prod1 ]
        tags = {
            "Environment" = "Production"
            "Role" = "AMQP"
        }
        firewall = merge(module.uksouth_firewall.peering, {rule_priority = 200})
    }
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
