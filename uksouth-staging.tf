module "uksouth_staging_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.8.0"
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
            }
        ]
    }

    bink_sh_zone_id = module.uksouth-dns.bink-sh[2]
    bink_host_zone_id = module.uksouth-dns.bink-host[2]

    managed_identities = local.managed_identities

    aks = {
        staging = merge(local.aks_config_defaults, {
            name = "staging"
            cidr = local.aks_cidrs.uksouth.staging
            maintenance_day = "Tuesday"
            iam = merge(local.aks_iam_defaults, {})
            firewall = merge(local.aks_firewall_defaults, {
                rule_priority = 1200
                ingress = merge(local.aks_ingress_defaults, {
                    public_ip = module.uksouth-firewall.public_ips.2.ip_address
                })
            })
        })
    }
}

module "uksouth_staging_aks_flux" {
    source = "github.com/binkhq/tf-azurerm_environment//submodules/flux?ref=5.8.0"
    flux_config = module.uksouth_staging_environment.aks_flux_config.staging
}
