module "uksouth_staging_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.18.7"
    providers = {
        azurerm = azurerm.uk_staging
        azurerm.core = azurerm
    }
    resource_group_name = "uksouth-staging"
    location = "uksouth"
    tags = {
        "Environment" = "Staging",
    }

    vnet_cidr = "192.168.100.0/24"

    loganalytics_id = module.uksouth_loganalytics.id

    postgres_iam = {}

    keyvault_iam = {
        Backend = {
            object_id = local.aad_group.backend,
            role = "Reader",
        },
        QA = {
            object_id = local.aad_group.qa,
            role = "Reader",
        },
    }

    storage_iam = {
        Backend = {
            storage_id = "common",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        QA = {
            storage_id = "common",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
    }

    keyvault_users = {
        Backend = local.aad_group.backend,
        QA = local.aad_group.qa,
        Architecture = local.aad_group.architecture
        SecOps = local.aad_group.cyber_sec,
    }

    postgres_flexible_config = {
        common = {
            name = "bink-uksouth-staging"
            version = "13"
            sku_name = "GP_Standard_D2ds_v4"
            storage_mb = 131072
            high_availability = false
            databases = [
                "api_reflector",
                "atlas",
                "carina",
                "eos",
                "europa",
                "hades",
                "harmonia",
                "hermes",
                "midas",
                "polaris",
                "pontus",
                "postgres",
                "vela",
                "zagreus",
                "snowstorm",
            ]
        }
    }

    storage_config = {
        common = {
            name                     = "binkuksouthstaging",
            account_replication_type = "ZRS",
            account_tier             = "Standard"
        }
    }
    storage_management_policy_config = {
        common = [
            {
                name              = "backupshourly",
                enabled           = true,
                prefix_match      = ["backups/hourly"],
                delete_after_days = 30
            },
            {
                name              = "backupsweekly",
                enabled           = true,
                prefix_match      = ["backups/weekly"],
                delete_after_days = 90
            },
            {
                name              = "backupsyearly",
                enabled           = true,
                prefix_match      = ["backups/yearly"],
                delete_after_days = 1095
            },
            {
                name              = "qareports",
                enabled           = true,
                prefix_match      = ["qareports/"],
                delete_after_days = 30
            },
        ]
    }

    bink_sh_zone_id = module.uksouth-dns.dns_zones.bink_sh.root.id
    bink_host_zone_id = module.uksouth-dns.dns_zones.bink_host.public.id

    managed_identities = local.managed_identities

    aks = {
        staging = merge(local.aks_config_defaults, {
            name = "staging"
            cidr = local.cidrs.uksouth.aks.staging
            dns = local.aks_dns.staging_defaults
            maintenance_day = "Tuesday"
            zones = ["1","2","3"]
            iam = merge(local.aks_iam_defaults, {})
            firewall = merge(local.aks_firewall_defaults, {rule_priority = 1200})
        })
    }
}

module "uksouth_staging_datawarehouse" {
    source = "./uksouth/datawarehouse"
    providers = {
        azurerm = azurerm.uk_staging
        azurerm.core = azurerm
    }
    common = {
        environment = "staging"
        location = "uksouth"
        cidr = local.cidrs.uksouth.datawarehouse.staging
        private_dns = local.private_dns.staging_defaults
        firewall_ip = module.uksouth-firewall.firewall_ip
        loganalytics_id = module.uksouth_loganalytics.id
        postgres_dns = module.uksouth_staging_environment.postgres_flexible_server_dns_link
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
                vnet_id = module.uksouth_staging_environment.peering.vnet_id
                vnet_name = module.uksouth_staging_environment.peering.vnet_name
                resource_group = module.uksouth_staging_environment.peering.resource_group_name
            }
        }        
    }
}
