locals {
    subscriptions = {
        uk_core = { id = "0add5c8e-50a6-4821-be0f-7a47c879b009" },
        uk_production = { id = "79560fde-5831-481d-8c3c-e812ef5046e5" },
        uk_preprod = { id = "6e685cd8-73f6-4aa6-857c-04ed9b21d17d" },
        uk_staging = { id = "457b0db5-6680-480f-9e77-2dafb06bd9dc" },
        uk_dev = { id = "794aa787-ec6a-40dd-ba82-0ad64ed51639" },
        uk_sandbox = { id = "957523d8-bbe2-4f68-8fae-95975157e91c" },
    }

    aks_config_defaults = {
        updates = "rapid"
        node_max_count = 10
        maintenance_day = "Monday"
        dns = local.aks_dns.dev_defaults
        aad_admin_group_object_ids = [ "0140ccf4-f68c-4daa-b531-97e5292ec364" ] # Kubernetes - Non-Prod - Admins
    }

    aks_config_defaults_prod = merge(local.aks_config_defaults, {
        updates = "stable"
        sku = "Standard"
        maintenance_day = "Thursday"
        aad_admin_group_object_ids = null
    })

    aks_iam_non_production = {
        "readers" = {
            object_id = "763319e1-e8d3-4a71-91eb-8ff980a55302",
            role = "Azure Kubernetes Service RBAC Reader",
        }
        "writers" = {
            object_id = "34f05ce7-fdbe-49bf-b285-2937c548aab5",
            role = "Azure Kubernetes Service RBAC Writer",
        }
        "admins" = {
            object_id = "0140ccf4-f68c-4daa-b531-97e5292ec364",
            role = "Azure Kubernetes Service RBAC Admin",
        }
    }

    aks_iam_production = {
        "readers" = {
            object_id = "6fd82111-210c-461a-bce3-8ea6ff0c1313"
            role = "Azure Kubernetes Service RBAC Reader",
        }
        "writers" = {
            object_id = "3c1cbd27-81ce-4938-a4c8-fd2171971d4e",
            role = "Azure Kubernetes Service RBAC Writer",
        }
        "admins" = {
            object_id = "d3a25905-88a1-4820-9384-9e6b2d05283f",
            role = "Azure Kubernetes Service RBAC Admin",
        }
    }

    aks_firewall_defaults = {
        config = module.uksouth_firewall.config
    }

    cidrs = {
        uksouth = {
            firewall = "192.168.0.0/24"
            opensearch = "192.168.1.0/24"
            wireguard = "192.168.2.0/24"
            bastion = "192.168.4.0/24"
            sftp = "192.168.20.0/24"
            tableau = "192.168.101.0/24"
            aks = {
                tools = "10.50.0.0/16"
                dev = "10.40.0.0/16"
                staging = "10.30.0.0/16"
                sandbox = "10.20.0.0/16"
                prod0 = "10.10.0.0/16"
                prod1 = "10.11.0.0/16"
            },
            amqp = {
                prod = "192.168.50.0/24"
            }
            datawarehouse = {
                staging = "192.168.201.0/24"
                prod = "192.168.200.0/24"
            }
        }
    }

    secure_origins = [
        "62.64.135.206/32", # Ascot Primary - Giganet
        "194.74.152.8/29",  # Ascot Backup - BT
        "217.169.3.233/32",  # cpressland@bink.com
        "81.2.99.144/29",  # cpressland@bink.com
        "31.125.46.20/32",  # nread@bink.com
        "51.105.20.158/32",  # Wireguard IP TODO: Bring this from module
        "81.133.125.233/32", # Thenuja, not static, will rotate.
    ]
    secure_origins_v6 = [
        "2001:8b0:b130::/48", # cpressland@bink.com
        "2a05:87c1:017c::/64", # Ascot Primary - Giganet
        "2a00:23a8:50:1400::1/64", # Thenuja, should be static unless BT implemented IPv6 improperly
    ]
    lloyds_origins_v4 = [
        "141.92.129.40/29", # Peterborough
        "141.92.67.40/29", # Horizon
    ]
    managed_identities = {
        fakicorp = { kv_access = "rw" },
        angelia = { kv_access = "ro" },
        europa = { kv_access = "rw" },
        harmonia = { kv_access = "ro" },
        hermes = { kv_access = "ro" },
        eos = { kv_access = "ro" },
        polaris = { kv_access = "ro" },
        event-horizon = { kv_access = "ro" },
        metis = { kv_access = "ro" },
        midas = { kv_access = "ro" },
        azuregcpvaultsync = { kv_access = "ro" },
        pyqa = { kv_access = "ro" },
        vela = { kv_access = "ro" },
        zephyrus = { kv_access = "ro" },
        carina = { kv_access = "ro" },
        styx = { kv_access = "ro" },
        cyclops = { kv_access = "ro" },
        snowstorm = { kv_access = "ro" },
        cosmos = { kv_access = "ro" },
        kiroshi = {kv_access = "ro"},
        boreas = {kv_access = "ro"},
    }

    aad_group = {
        architecture = "fb26c586-72a5-4fbc-b2b0-e1c28ef4fce1"
        data_mgmt = "13876e0a-d625-42ff-89aa-3f6904b2f073"
        qa = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d"
        cyber_sec = "b56bc76d-1af5-4e44-8784-7ee7a44cc0c1"
        devops = "aac28b59-8ac3-4443-bccc-3fb820165a08"
        backend = "219194f6-b186-4146-9be7-34b731e19001"
    }
    aad_user = {
        chris_pressland = "48aca6b1-4d56-4a15-bc92-8aa9d97300df"
        nathan_read = "bba71e03-172e-4d07-8ee4-aad029d9031d"
        thenuja_viknarajah = "e69fd5a7-8b6c-4ac5-8df0-c88c77df0a12"
        terraform = "4869640a-3727-4496-a8eb-f7fae0872410"
        jo_raine = "ac4c9b34-2e1b-4e46-bfca-2d64e1a3adbc"
        mick_latham = "343299d4-0a39-4109-adce-973ad29d0183"
        chris_latham = "607482a3-07fa-4b24-8af0-5b84df6ca7c6"
        christian_prior = "ae282437-d730-4342-8914-c936e8289cdc"
        azhar_khan = "6f0e18dc-210c-405d-847e-cad38d195115"
        kashim_aziz = "b004c980-3e08-4237-b8e2-d6e65d2bef3f"
        martin_marsh = "3c92809d-91a4-456f-a161-a8b9df4c01e1"
        stewart_prerrygove = "c7c13573-de9a-443e-a1a7-cc272cb26e2e"
        francesco_milani = "dbcb7a78-da53-4fb9-a5a0-4f5d9a1e664c"
        tony_truong = "f66db5ed-a4e3-485f-9112-c42ee2fe85c5"
        michael_morar = "8288a1d3-0bfb-4561-a91b-30f58045ca73"
    }
    aad_apps = {}

    prod_cluster_ingress_subdomains = [ "api", "policies", "help", "link", "data", "api2-docs", "bpl" ]
}

terraform {
    backend "azurerm" {
        storage_account_name = "binkitops"
        container_name = "terraform"
        key = "azure.tfstate"
        access_key = "bRtDCEojOLE122v5glr8g+kyxLytWMp/OSPsjqmiXr972xPOGNRwXOBFPCCze1Ge5dk+imhW+ZdKeOFahNVEFg=="
    }

    required_version = ">= 1.4.0"

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "3.55.0"
        }
        random = {
            source = "hashicorp/random"
        }
    }
}

data "azurerm_subscription" "primary" {}

module "uksouth-core" {
    source = "./uksouth/core"
}

module "uksouth_bastion" {
    source = "./uksouth/bastion"

    common = {
        firewall = {
            name = module.uksouth_firewall.firewall_name
            resource_group = module.uksouth_firewall.resource_group_name
            ip_address = module.uksouth_firewall.firewall_ip
            public_ip = module.uksouth_firewall.public_ips.0.ip_address
            vnet_name = module.uksouth_firewall.vnet_name
            vnet_id = module.uksouth_firewall.vnet_id
        }
        private_dns = local.private_dns.core_defaults
        cidr = local.cidrs.uksouth.bastion
        loganalytics_id = module.uksouth_loganalytics.id
    }
}

module "uksouth_wireguard" {
    source = "./uksouth/wireguard"
    common = {
        firewall = {
            resource_group = module.uksouth_firewall.resource_group_name
            ip_address = module.uksouth_firewall.firewall_ip
            vnet_name = module.uksouth_firewall.vnet_name
            vnet_id = module.uksouth_firewall.vnet_id
        }
        private_dns = local.private_dns.core_defaults
        cidr = local.cidrs.uksouth.wireguard
        loganalytics_id = module.uksouth_loganalytics.id
    }
}

module "uksouth-dns" {
    source = "./uksouth/dns"
    bink_sh_managed_identities = {
        uksouth_dev = module.uksouth_dev.managed_identities.cert-manager
        uksouth_perf = module.uksouth_perf.managed_identities.cert-manager
        uksouth_prod = module.uksouth_prod.managed_identities.cert-manager
        uksouth_lloyds = module.uksouth_lloyds.managed_identities.cert-manager
        uksouth_retail = module.uksouth_retail.managed_identities.cert-manager
        uksouth_staging = module.uksouth_staging.managed_identities.cert-manager
        uksouth_barclays = module.uksouth_barclays.managed_identities.cert-manager
    }
}

module "uksouth_frontdoor" {
    source = "./uksouth/frontdoor_premium"
    common = {
        dns_zone = {
            id = module.uksouth-dns.dns_zones.bink_com.root.id
            name = module.uksouth-dns.dns_zones.bink_com.root.name
            resource_group = module.uksouth-dns.dns_zones.resource_group.name
        }
        loganalytics_id = module.uksouth_loganalytics.id
        secure_origins = {
          ipv4 = local.secure_origins
          ipv6 = local.secure_origins_v6
        }
        key_vault = {
            admin_object_ids = {
                "devops" = local.aad_group.devops
            }
            admin_ips = local.secure_origins
        }
    }
}

module "uksouth_firewall" {
    source = "./uksouth/firewall"

    ip_range = local.cidrs.uksouth.firewall
    sftp_ip_address = module.uksouth_sftp.ip_address
    loganalytics_id = module.uksouth_loganalytics.id
    secure_origins = local.secure_origins
    lloyds_origins = local.lloyds_origins_v4
    production_cidrs = [ local.cidrs.uksouth.aks.prod0, local.cidrs.uksouth.aks.prod1 ]
    aks_cidrs = local.cidrs.uksouth.aks
}

module "uksouth-storage" {
    source = "./uksouth/storage"
    loganalytics_id = module.uksouth_loganalytics.id
}

module "uksouth_opensearch" {
    source = "./uksouth/opensearch"
    peers = {
        firewall = {
            vnet_id = module.uksouth_firewall.vnet_id
            vnet_name = module.uksouth_firewall.vnet_name
            resource_group_name = module.uksouth_firewall.resource_group_name
        }
    }
    private_dns = local.private_dns.root_defaults # OpenSearch requires CN changes to support moving this to core
    ip_range = local.cidrs.uksouth.opensearch
}

module "uksouth_sftp" {
    source = "./uksouth/sftp"
    peers = {
        firewall = {
            vnet_id = module.uksouth_firewall.vnet_id
            vnet_name = module.uksouth_firewall.vnet_name
            resource_group_name = module.uksouth_firewall.resource_group_name
        }
    }
    loganalytics_id = module.uksouth_loganalytics.id
    private_dns = local.private_dns.core_defaults
    ip_range = local.cidrs.uksouth.sftp
}

module "uksouth_loganalytics" {
    source = "./uksouth/loganalytics"
    kiroshi_ids = [
        module.uksouth_prod.managed_identities.kiroshi
    ]
}

module "uksouth_wordpress" {
    source = "./uksouth/wordpress"
    secure_origins = local.secure_origins
    loganalytics_id = module.uksouth_loganalytics.id
    dns = {
        zone = module.uksouth-dns.dns_zones.bink_com.root.name
        resource_group = module.uksouth-dns.dns_zones.resource_group.name
    }
}
