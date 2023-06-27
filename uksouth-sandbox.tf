module "uksouth_sandbox_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.20.0"
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

    postgres_iam = {}

    keyvault_iam = {}

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
    }

    keyvault_users = {
        Backend = local.aad_group.backend,
        QA = local.aad_group.qa,
        Architecture = local.aad_group.architecture,
        SecOps = local.aad_group.cyber_sec,
    }

    additional_keyvaults = [
        "bink-uksouth-barclay-oat",
        "bink-uksouth-perf-api-v1",
        "bink-uksouth-perf-api-v2",
        "bink-uksouth-perf-txm",
        "bink-uksouth-perf-bpl",
        "bink-uksouth-perf-data",
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
                "perf_txm_api_reflector",
                "perf_txm_atlas",
                "perf_txm_europa",
                "perf_txm_harmonia",
                "perf_txm_hades",
                "perf_txm_hermes",
                "perf_bpl_api_reflector",
                "perf_bpl_carina",
                "perf_bpl_cosmos",
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
        barclays-oat = {
            name = "binkuksouthbarclaysoat",
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
            sku = "Standard"
            node_count = 8
            maintenance_day = "Wednesday"
            zones = ["1","2","3"]
            iam = merge(local.aks_iam_non_production, {})
            firewall = merge(local.aks_firewall_defaults, {rule_priority = 1400})
        })
    }
}

locals {
    sandbox_common = {
        allowed_hosts = {
            ipv4 = local.secure_origins
            ipv6 = local.secure_origins_v6
        }
        iam = {
            (local.aad_user.chris_pressland) = { assigned_to = ["st_rw", "kv_su"] }
            (local.aad_user.nathan_read) = { assigned_to = ["st_rw", "kv_su"] }
            (local.aad_user.thenuja_viknarajah) = { assigned_to = ["st_rw", "kv_su"] }
            (local.aad_user.terraform) = { assigned_to = ["kv_su"] }
            (local.aad_group.backend) = { assigned_to = ["rg", "aks_rw", "st_rw", "kv_rw"] }
            (local.aad_group.qa) = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
            (local.aad_group.architecture) = { assigned_to = ["rg", "aks_rw", "kv_ro"] }
        }
        managed_identities = {
            "angelia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "cert-manager" = { namespaces = ["cert-manager"] }
            "europa" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "harmonia" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "hermes" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "keyvault2kube" = { assigned_to = ["kv_ro"], namespaces = ["kube-system"] }
            "metis" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
            "midas" = { assigned_to = ["kv_ro"], namespaces = ["olympus"] }
        }
        kube = {
            enabled = true
            authorized_ip_ranges = local.secure_origins,
            pool_vm_size = "Standard_B4ms"
            pool_os_disk_size_gb = 32
        }
        storage = {
            enabled = true
            rules = [
                { name = "backupshourly", prefix_match = ["backups/hourly"], delete_after_days = 30 },
                { name = "backupsweekly", prefix_match = ["backups/weekly"], delete_after_days = 90 },
                { name = "backupsyearly", prefix_match = ["backups/yearly"], delete_after_days = 1095 },
            ]
        }
    }
}

module "uksouth_retail" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_sandbox
        azurerm.core = azurerm
    }
    common = {
        name = "retail"
        location = "uksouth"
        cidr = "10.21.0.0/16"
    }
    allowed_hosts = local.sandbox_common.allowed_hosts
    iam = local.sandbox_common.iam
    managed_identities = local.sandbox_common.managed_identities
    kube = local.sandbox_common.kube
    storage = local.sandbox_common.storage
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = true, sku = "B_Standard_B1ms", storage_mb = 32768 }
    redis = { enabled = false }
}

module "uksouth_barclays" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_sandbox
        azurerm.core = azurerm
    }
    common = {
        name = "barclays"
        location = "uksouth"
        cidr = "10.22.0.0/16"
    }
    allowed_hosts = local.sandbox_common.allowed_hosts
    iam = local.sandbox_common.iam
    managed_identities = local.sandbox_common.managed_identities
    kube = local.sandbox_common.kube
    storage = local.sandbox_common.storage
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = true, sku = "B_Standard_B1ms", storage_mb = 32768 }
    redis = { enabled = false }
}

module "uksouth_lloyds" {
    source = "./cluster"
    providers = {
        azurerm = azurerm.uksouth_sandbox
        azurerm.core = azurerm
    }
    common = {
        name = "lloyds"
        location = "uksouth"
        cidr = "10.23.0.0/16"
    }
    allowed_hosts = local.sandbox_common.allowed_hosts
    iam = local.sandbox_common.iam
    managed_identities = local.sandbox_common.managed_identities
    kube = local.sandbox_common.kube
    storage = local.sandbox_common.storage
    loganalytics = { enabled = true }
    keyvault = { enabled = true }
    postgres = { enabled = true, sku = "B_Standard_B1ms", storage_mb = 32768 }
    redis = { enabled = false }
}
