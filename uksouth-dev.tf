module "uksouth_dev_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.1.2"
    providers = {
        azurerm = azurerm.uk_dev
        azurerm.core = azurerm
    }
    resource_group_name = "uksouth-dev"
    location = "uksouth"
    tags = {
        "Environment" = "Dev",
    }

    vnet_cidr = "192.168.100.0/24"

    loganalytics_id = module.uksouth_loganalytics.id

    postgres_iam = {
        Backend = {
            object_id = local.aad_group.backend,
            role = "Reader",
        },
    }

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
            name = "bink-uksouth-dev"
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
                "helios",
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

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    storage_config = {
        common = {
            name                     = "binkuksouthdev",
            account_replication_type = "ZRS",
            account_tier             = "Standard"
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
                delete_after_days = 90
            },
            {
                name = "backupsyearly",
                enabled = true,
                prefix_match = ["backups/yearly"],
                delete_after_days = 1095
            }
        ]
    }

    bink_sh_zone_id = module.uksouth-dns.bink-sh[2]
    bink_host_zone_id = module.uksouth-dns.bink-host[2]

    managed_identities = local.managed_identities

    secret_namespaces = "default,bpl,portal,monitoring,backups"

    aks = {
        dev = merge(local.aks_config_defaults, {
            name = "dev"
            cidr = local.aks_cidrs.uksouth.dev
            iam = merge(local.aks_iam_defaults, {})
            firewall = merge(local.aks_firewall_defaults, {
                rule_priority = 1300
                ingress = merge(local.aks_ingress_defaults, {})
            })
        })
    }
}

module "uksouth_dev_aks_flux" {
    source = "github.com/binkhq/tf-azurerm_environment//submodules/flux?ref=5.1.2"
    flux_config = module.uksouth_dev_environment.aks_flux_config.dev
}

module "uksouth_dev_binkweb" {
    source = "github.com/binkhq/tf-azurerm_binkweb?ref=2.1.1"
    providers = {
        azurerm = azurerm.uk_dev
    }
    resource_group_name = "uksouth-dev"
    location = "uksouth"
    environment = "Development"

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    loganalytics_id = module.uksouth_loganalytics.id

    storage_accounts = {
        wallet = {
            name = "binkwebdevbink"
        }
        wasabi = {
            name = "binkwebdevwasabi"
        }
        fatface = {
            name = "binkwebdevfatface"
        }
    }
}
