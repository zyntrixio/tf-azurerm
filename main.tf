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
        maintenance_day = "Monday"
        dns = local.aks_dns.dev_defaults
    }

    aks_config_defaults_prod = merge(local.aks_config_defaults, {
        updates = "stable"
        sku = "Paid"
        node_max_count = 10
        maintenance_day = "Thursday"
    })

    aks_iam_defaults = {
        architecture = {
            object_id = local.aad_group.architecture
            role = "Azure Kubernetes Service RBAC Writer"
        }
        data_mgmt = {
            object_id = local.aad_group.data_mgmt
            role = "Azure Kubernetes Service RBAC Writer"
        }
        backend = {
            object_id = local.aad_group.backend
            role = "Azure Kubernetes Service RBAC Writer"
        }
        qa = {
            object_id = local.aad_group.qa
            role = "Azure Kubernetes Service RBAC Writer"
        }
    }

    aks_iam_production = {
        chris_latham = {
            object_id = local.aad_user.chris_latham
            role = "Azure Kubernetes Service RBAC Writer"
        }
        christian_prior = {
            object_id = local.aad_user.christian_prior
            role = "Azure Kubernetes Service RBAC Writer"
        }
        kashim_aziz = {
            object_id = local.aad_user.kashim_aziz
            role = "Azure Kubernetes Service RBAC Writer"
        }
        mick_latham = {
            object_id = local.aad_user.mick_latham
            role = "Azure Kubernetes Service RBAC Writer"
        }
        martin_marsh = {
            object_id = local.aad_user.martin_marsh
            role = "Azure Kubernetes Service RBAC Writer"
        }
        stewart_prerrygove = {
            object_id = local.aad_user.stewart_prerrygove
            role = "Azure Kubernetes Service RBAC Writer"
        }
        francesco_milani = {
            object_id = local.aad_user.francesco_milani
            role = "Azure Kubernetes Service RBAC Reader"
        }
    }

    aks_firewall_defaults = {
        config = module.uksouth-firewall.config
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
        "194.74.152.8/29",  # Ascot Bink HQ
        "89.38.121.228/30",  # London Bink Scrub Office
        "217.169.3.233/32",  # cpressland@bink.com
        "81.2.99.144/29",  # cpressland@bink.com
        "31.125.46.20/32",  # nread@bink.com
        "51.105.20.158/32",  # Wireguard IP TODO: Bring this from module
        "81.133.125.233/32", # Thenuja, not static, will rotate.
    ]
    secure_origins_v6 = [
        "2001:8b0:b130:a52d::/64", # cpressland@bink.com
        "2a00:23c7:da8c:4201::/64", # Thenuja, should be static unless BT implemented IPv6 improperly
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
        jo_raine = "ac4c9b34-2e1b-4e46-bfca-2d64e1a3adbc"
        mick_latham = "343299d4-0a39-4109-adce-973ad29d0183"
        chris_latham = "607482a3-07fa-4b24-8af0-5b84df6ca7c6"
        christian_prior = "ae282437-d730-4342-8914-c936e8289cdc"
        azhar_khan = "6f0e18dc-210c-405d-847e-cad38d195115"
        kashim_aziz = "b004c980-3e08-4237-b8e2-d6e65d2bef3f"
        martin_marsh = "3c92809d-91a4-456f-a161-a8b9df4c01e1"
        stewart_prerrygove = "c7c13573-de9a-443e-a1a7-cc272cb26e2e"
        francesco_milani = "dbcb7a78-da53-4fb9-a5a0-4f5d9a1e664c"
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

    required_version = ">= 1.3.7"

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "3.39.1"
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
            name = module.uksouth-firewall.firewall_name
            resource_group = module.uksouth-firewall.resource_group_name
            ip_address = module.uksouth-firewall.firewall_ip
            public_ip = module.uksouth-firewall.public_ips.0.ip_address
            vnet_name = module.uksouth-firewall.vnet_name
            vnet_id = module.uksouth-firewall.vnet_id
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
            resource_group = module.uksouth-firewall.resource_group_name
            ip_address = module.uksouth-firewall.firewall_ip
            vnet_name = module.uksouth-firewall.vnet_name
            vnet_id = module.uksouth-firewall.vnet_id
        }
        private_dns = local.private_dns.core_defaults
        cidr = local.cidrs.uksouth.wireguard
        loganalytics_id = module.uksouth_loganalytics.id
    }
}

module "uksouth-dns" {
    source = "./uksouth/dns"
}

module "uksouth-alerts" {
    source = "./uksouth/alerts"
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

module "uksouth-firewall" {
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
            vnet_id = module.uksouth-firewall.vnet_id
            vnet_name = module.uksouth-firewall.vnet_name
            resource_group_name = module.uksouth-firewall.resource_group_name
        }
    }
    private_dns = local.private_dns.root_defaults # OpenSearch requires CN changes to support moving this to core
    ip_range = local.cidrs.uksouth.opensearch
}

module "uksouth_sftp" {
    source = "./uksouth/sftp"
    peers = {
        firewall = {
            vnet_id = module.uksouth-firewall.vnet_id
            vnet_name = module.uksouth-firewall.vnet_name
            resource_group_name = module.uksouth-firewall.resource_group_name
        }
    }
    loganalytics_id = module.uksouth_loganalytics.id
    private_dns = local.private_dns.core_defaults
    ip_range = local.cidrs.uksouth.sftp
}

module "uksouth_loganalytics" {
    source = "./uksouth/loganalytics"
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
