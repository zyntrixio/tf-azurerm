module "uksouth_prod_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.18.7"
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
            api_ip_ranges = concat(local.secure_origins, [module.uksouth-firewall.public_ip_prefix])
            iam = merge(local.aks_iam_production, {})
            firewall = merge(local.aks_firewall_defaults, {rule_priority = 1100})
        })
        prod1 = merge(local.aks_config_defaults_prod, {
            name = "prod1"
            cidr = local.cidrs.uksouth.aks.prod1
            dns = local.aks_dns.prod_defaults
            maintenance_day = "Friday"
            api_ip_ranges = concat(local.secure_origins, [module.uksouth-firewall.public_ip_prefix])
            iam = merge(local.aks_iam_production, {})
            firewall = merge(local.aks_firewall_defaults, {rule_priority = 1110})
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
        vnet_id = module.uksouth-firewall.vnet_id,
        vnet_name = module.uksouth-firewall.vnet_name,
        resource_group_name = module.uksouth-firewall.resource_group_name,
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
        firewall = merge(module.uksouth-firewall.peering, {rule_priority = 200})
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
        firewall_ip = module.uksouth-firewall.firewall_ip
        postgres_dns = module.uksouth_prod_environment.postgres_flexible_server_dns_link
        vms = {
            airbyte = { size = "Standard_D2as_v5" }
            prefect = { size = "Standard_D2as_v5" }
        }
        peering = {
            firewall = {
                vnet_id = module.uksouth-firewall.peering.vnet_id
                vnet_name = module.uksouth-firewall.peering.vnet_name
                resource_group = module.uksouth-firewall.peering.rg_name
            }
            environment = {
                vnet_id = module.uksouth_prod_environment.peering.vnet_id
                vnet_name = module.uksouth_prod_environment.peering.vnet_name
                resource_group = module.uksouth_prod_environment.peering.resource_group_name
            }
        }
    }
}
