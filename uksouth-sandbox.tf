module "uksouth_sandbox_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=2.9.3"
    providers = {
        azurerm = azurerm.uk_sandbox
    }
    resource_group_name = "uksouth-sandbox"
    location = "uksouth"
    tags = {
        "Environment" = "Sandbox",
    }

    vnet_cidr = "192.168.100.0/24"

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
                "perf_bpl_carina",
                "perf_bpl_polaris",
                "perf_bpl_vela",
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

    secret_namespaces = "default,barclays-oat,barclays-sit,lloyds-sit,monitoring,perf-api-v1,perf-api-v2,perf-bpl,perf-txm"
    eventhub_authid   = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
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
    }
    bink_sh_zone_id = module.uksouth-dns.bink-sh[2]
    bink_host_zone_id = module.uksouth-dns.bink-host[2]

    managed_identities = merge(local.managed_identities, {pyxis={kv_access="ro"}})
}

module "uksouth_sandbox_cluster_0" {
    source = "github.com/binkhq/tf-azurerm_cluster?ref=2.14.0"
    providers = {
        azurerm      = azurerm.uk_sandbox
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-sandbox-k0"
    cluster_name = "sandbox0"
    location = "uksouth"
    vnet_cidr = "10.189.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    bifrost_version = "4.22.0"
    ubuntu_version = "20.04"
    controller_vm_size = "Standard_D2as_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_scaleset_size = 10
    use_scaleset = true
    max_pods_per_host = 100
    log_analytics_workspace_id = module.uksouth_sandbox_environment.log_analytics_id
    controller_storage_type = "StandardSSD_LRS"

    cluster_ingress_subdomains = [
        "api2-docs", "api2-docs", "barclays-oat", "barclays-sit",
        "lloyds-sit", "lloyds-sit-reflector", "perf-api-v1", "perf-api-v2",
        "perf-bpl", "perf-txm"
    ]

    prometheus_subnet = "10.33.0.0/18"

    flux_environment = "uksouth-sandbox"

    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity

    # DNS zones
    private_dns = module.uksouth-dns.private_dns
    public_dns  = module.uksouth-dns.public_dns

    # Peers    
    peers = {
        firewall = {
            vnet_id = module.uksouth-firewall.vnet_id
            vnet_name = module.uksouth-firewall.vnet_name
            resource_group_name = module.uksouth-firewall.resource_group_name
        }
        elasticsearch = {
            vnet_id = module.uksouth-elasticsearch.vnet_id
            vnet_name = module.uksouth-elasticsearch.vnet_name
            resource_group_name = module.uksouth-elasticsearch.resource_group_name
        }
    }
    subscription_peers = {
        environment = {
            vnet_id = module.uksouth_sandbox_environment.peering.vnet_id
            vnet_name = module.uksouth_sandbox_environment.peering.vnet_name
            resource_group_name = module.uksouth_sandbox_environment.peering.resource_group_name
        }
    }

    firewall = {
        firewall_name = module.uksouth-firewall.firewall_name
        resource_group_name = module.uksouth-firewall.resource_group_name
        ingress_priority = 1400
        rule_priority = 1400
        public_ip = module.uksouth-firewall.public_ips.4.ip_address
        secure_origins = local.secure_origins
        ingress_source = "*"
        ingress_http = 8000
        ingress_https = 4000
        ingress_controller  = 6000
    }

    postgres_servers = module.uksouth_sandbox_environment.postgres_servers
    postgres_flexible_server_dns_link = module.uksouth_sandbox_environment.postgres_flexible_server_dns_link

    tags = {
        "Environment" = "Sandbox",
    }
}
