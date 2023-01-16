module "uksouth_sandbox_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.18.6"
    providers = {
        azurerm = azurerm.uk_sandbox
        azurerm.core = azurerm
    }
    resource_group_name = "uksouth-sandbox"
    location = "uksouth"
    tags = {
        "Environment" = "Sandbox",
    }

    vnet_cidr = "192.168.100.0/24"

    loganalytics_id = module.uksouth_loganalytics.id

    postgres_iam = {
        Backend = {
            object_id = local.aad_group.backend,
            role      = "Contributor",
        },
        QA = {
            object_id = local.aad_group.qa,
            role      = "Contributor",
        },
    }

    keyvault_iam = {
        Backend = {
            object_id = local.aad_group.backend,
            role      = "Reader",
        },
        QA = {
            object_id = local.aad_group.qa,
            role      = "Reader",
        },
        Architecture = {
            object_id = local.aad_group.architecture,
            role      = "Reader"
        }
    }

    storage_iam = {
        common-backend = {
            storage_id = "common",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        common-qa = {
            storage_id = "common",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
        barclays-sit-backend = {
            storage_id = "barclays-sit",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        barclays-sit-qa = {
            storage_id = "barclays-sit",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
        barclays-oat-backend = {
            storage_id = "barclays-oat",
            object_id  = local.aad_group.backend,
            role       = "Contributor",
        },
        barclays-oat-qa = {
            storage_id = "barclays-oat",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
        lloyds-sit-backend = {
            storage_id = "lloyds-sit",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        lloyds-sit-qa = {
            storage_id = "lloyds-sit",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
        perf-api-v1-backend = {
            storage_id = "perf-api-v1",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        perf-api-v1-qa = {
            storage_id = "perf-api-v1",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
        perf-api-v2-backend = {
            storage_id = "perf-api-v2",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        perf-api-v2-qa = {
            storage_id = "perf-api-v2",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
        perf-txm-backend = {
            storage_id = "perf-txm",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        perf-txm-qa = {
            storage_id = "perf-txm",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
        perf-bpl-backend = {
            storage_id = "perf-bpl",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        perf-bpl-qa = {
            storage_id = "perf-bpl",
            object_id  = local.aad_group.qa,
            role       = "Contributor",
        },
        perf-data-backend = {
            storage_id = "perf-data",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        perf-data-qa = {
            storage_id = "perf-data",
            object_id  = local.aad_group.qa,
            role       = "Contributor",
        },
        retail-backend = {
            storage_id = "retail",
            object_id = local.aad_group.backend,
            role = "Contributor",
        },
        retail-qa = {
            storage_id = "retail",
            object_id = local.aad_group.qa,
            role = "Contributor",
        },
    }

    keyvault_users = {
        Backend = local.aad_group.backend,
        QA = local.aad_group.qa,
        Architecture = local.aad_group.architecture,
        SecOps = local.aad_group.cyber_sec,
    }

    additional_keyvaults = [
        "bink-uksouth-barclay-sit",
        "bink-uksouth-barclay-oat",
        "bink-uksouth-lloyds-sit",
        "bink-uksouth-perf-api-v1",
        "bink-uksouth-perf-api-v2",
        "bink-uksouth-perf-txm",
        "bink-uksouth-perf-bpl",
        "bink-uksouth-perf-data",
        "bink-uksouth-retail"
    ]

    postgres_flexible_config = {
        common = {
            name = "bink-uksouth-sandbox"
            version = "13"
            sku_name = "GP_Standard_D8ds_v4"
            storage_mb = 1048576
            high_availability = false
            databases = [
                "postgres",
                "lloyds_sit_api_reflector",
                "lloyds_sit_atlas",
                "lloyds_sit_europa",
                "lloyds_sit_hades",
                "lloyds_sit_hermes",
                "lloyds_sit_midas",
                "lloyds_sit_pontus",
                "barclays_sit_api_reflector",
                "barclays_sit_atlas",
                "barclays_sit_europa",
                "barclays_sit_hades",
                "barclays_sit_hermes",
                "barclays_sit_midas",
                "barclays_sit_pontus",
                "barclays_oat_atlas",
                "barclays_oat_europa",
                "barclays_oat_hades",
                "barclays_oat_hermes",
                "barclays_oat_midas",
                "barclays_oat_pontus",
                "perf_api_v1_atlas",
                "perf_api_v1_europa",
                "perf_api_v1_hades",
                "perf_api_v1_hermes",
                "perf_api_v2_atlas",
                "perf_api_v2_europa",
                "perf_api_v2_hades",
                "perf_api_v2_hermes",
                "perf_txm_atlas",
                "perf_txm_europa",
                "perf_txm_harmonia",
                "perf_txm_hades",
                "perf_txm_hermes",
                "perf_bpl_api_reflector",
                "perf_bpl_carina",
                "perf_bpl_polaris",
                "perf_bpl_vela",
                "perf_data_api_reflector",
                "perf_data_atlas",
                "perf_data_europa",
                "perf_data_hades",
                "perf_data_harmonia",
                "perf_data_hermes",
                "perf_data_midas",
                "perf_data_pontus",
                "perf_data_tableau",
                "retail_api_reflector",
                "retail_atlas",
                "retail_europa",
                "retail_hades",
                "retail_hermes",
                "retail_midas",
                "retail_pontus",
            ]
        },
        archive = {
            name = "bink-uksouth-sandbox-archive"
            version = "13"
            sku_name = "GP_Standard_D2ds_v4"
            storage_mb = 1048576
            high_availability = false
            databases = [
                "postgres",
            ]
        },
    }

    redis_config = {
        txm = {
            name = "bink-uksouth-perf-txm",
        },
    }

    storage_config = {
        common = {
            name = "binkuksouthsandbox",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        barclays-sit = {
            name = "binkuksouthbarclayssit",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        barclays-oat = {
            name = "binkuksouthbarclaysoat",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        lloyds-sit = {
            name = "binkuksouthlloydssit",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        perf-api-v1 = {
            name = "binkuksouthperfapiv1",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        perf-api-v2 = {
            name = "binkuksouthperfapiv2",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        perf-txm = {
            name = "binkuksouthperftxm",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        perf-bpl = {
            name = "binkuksouthperfbpl",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        perf-data = {
            name = "binkuksouthperfdata",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
        retail = {
            name = "binkuksouthretail",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },

    }
    bink_sh_zone_id = module.uksouth-dns.dns_zones.bink_sh.root.id
    bink_host_zone_id = module.uksouth-dns.dns_zones.bink_host.public.id

    managed_identities = merge(local.managed_identities, {pyxis={kv_access="ro"}})

    aks = {
        sandbox = merge(local.aks_config_defaults, {
            name = "sandbox"
            cidr = local.cidrs.uksouth.aks.sandbox
            dns = local.aks_dns.sandbox_defaults
            updates = "stable"
            sku = "Paid"
            node_max_count = 20
            maintenance_day = "Wednesday"
            zones = ["1","2","3"]
            iam = merge(local.aks_iam_defaults, {
                azhar_khan = {
                    object_id = local.aad_user.azhar_khan
                    role = "Azure Kubernetes Service RBAC Admin"
                }
            })
            firewall = merge(local.aks_firewall_defaults, {rule_priority = 1400})
        })
    }
}
