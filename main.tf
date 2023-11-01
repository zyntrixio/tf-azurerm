locals {
    cidrs = {
        uksouth = {
            aks = {
                dev = "10.41.0.0/16"
                staging = "10.31.0.0/16"
                sandbox = "10.20.0.0/16"
                prod = "10.11.0.0/16"
            },
        },
    }
    secure_origins = [
        "62.64.135.206/32", # Ascot Primary - Giganet
        "80.87.29.254/32",  # London Primary - Scrub Office
        "217.169.3.233/32",  # cpressland@bink.com
        "81.2.99.144/29",  # cpressland@bink.com
        "31.125.46.20/32",  # nread@bink.com
        "51.105.20.158/32",  # Wireguard IP TODO: Bring this from module
        "81.133.125.233/32", # Thenuja, not static, will rotate.
        "20.49.208.61/32", # module.uksouth_vpn.ip_addresses.ipv4,
        "51.142.188.173/32", # module.ukwest_vpn.ip_addresses.ipv4,
    ]
    secure_origins_v6 = [
        "2001:8b0:b130::/48", # cpressland@bink.com
        "2a05:87c1:17c::/48", # Ascot Primary - Giganet
        "2a00:23a8:50:1400::/64", # Thenuja, should be static unless BT implemented IPv6 improperly
        "2603:1020:702:3::3a/128", # module.uksouth_vpn.ip_addresses.ipv6,
        "2603:1020:600::12c/128", # module.ukwest_vpn.ip_addresses.ipv6,
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
        prefect = {kv_access = "ro"},
    }

    aad_group = {
        architecture = "fb26c586-72a5-4fbc-b2b0-e1c28ef4fce1"
        data_mgmt = "13876e0a-d625-42ff-89aa-3f6904b2f073"
        qa = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d"
        cyber_sec = "b56bc76d-1af5-4e44-8784-7ee7a44cc0c1"
        devops = "aac28b59-8ac3-4443-bccc-3fb820165a08"
        backend = "219194f6-b186-4146-9be7-34b731e19001"
        ba = "27678d85-c6b3-49b5-b1b7-0792940f4e13"
    }
    aad_user = {
        chris_pressland = "48aca6b1-4d56-4a15-bc92-8aa9d97300df"
        nathan_read = "bba71e03-172e-4d07-8ee4-aad029d9031d"
        thenuja_viknarajah = "e69fd5a7-8b6c-4ac5-8df0-c88c77df0a12"
        daniel_hodgson = "103d8795-0975-4301-ae8c-795b21d80284"
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
        navya_james = "35632f94-054f-41d1-9006-9e34fa04210f"
        carla_gouws = "d14223a9-b07a-41ba-96c7-cf5526f6987b"
    }
    aad_apps = {}
}

terraform {
    backend "azurerm" {
        storage_account_name = "binkitops"
        container_name = "terraform"
        key = "azure.tfstate"
        access_key = "bRtDCEojOLE122v5glr8g+kyxLytWMp/OSPsjqmiXr972xPOGNRwXOBFPCCze1Ge5dk+imhW+ZdKeOFahNVEFg=="
    }

    required_version = ">= 1.5.4"

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "3.78.0"
        }
        azuread = {
            source  = "hashicorp/azuread"
            version = "2.45.0"
        }
        cloudamqp = {
            source = "cloudamqp/cloudamqp"
        }
        random = {
            source = "hashicorp/random"
        }
    }
}

module "uksouth_core" {
    source = "./uksouth/core"
}

module "uksouth_cloudamqp" {
    source = "./cloudamqp"
    subnet = "192.168.1.0/24"
}

module "uksouth_vpn" {
    source = "./vpn"
    common = {
        secure_origins_v4 = local.secure_origins
        secure_origins_v6 = local.secure_origins_v6
    }
    dns = {
        record = "vpn.gb"
        resource_group_name = module.uksouth_dns.resource_group_name
        zone_name = module.uksouth_dns.bink_com_zone
    }
    iam = [
        local.aad_user.daniel_hodgson,
    ]
}

module "uksouth_website" {
    source = "./website"
    common = {
        secure_origins_v4 = local.secure_origins
        secure_origins_v6 = local.secure_origins_v6
    }
    dns = {
        resource_group_name = module.uksouth_dns.resource_group_name
        zone_name = module.uksouth_dns.bink_com_zone
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
        cidr = "192.168.2.0/24"
        loganalytics_id = module.uksouth_loganalytics.id
        secure_origins_v4 = local.secure_origins
        secure_origins_v6 = local.secure_origins_v6
    }
}

module "uksouth_dns" {
    source = "./uksouth/dns"
    bink_sh_managed_identities = {
        uksouth_ait = module.uksouth_ait.managed_identities.cert-manager
        uksouth_dev = module.uksouth_dev.managed_identities.cert-manager
        uksouth_prod = module.uksouth_prod.managed_identities.cert-manager
        uksouth_lloyds = module.uksouth_lloyds.managed_identities.cert-manager
        uksouth_retail = module.uksouth_retail.managed_identities.cert-manager
        uksouth_staging = module.uksouth_staging.managed_identities.cert-manager
    }
}

module "uksouth_frontdoor" {
    source = "./uksouth/frontdoor"
    common = {
        dns_zone = {
            id = module.uksouth_dns.dns_zones.bink_com.root.id
            name = module.uksouth_dns.dns_zones.bink_com.root.name
            resource_group = module.uksouth_dns.dns_zones.resource_group.name
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

    ip_range = "192.168.0.0/24"
    loganalytics_id = module.uksouth_loganalytics.id
    secure_origins = local.secure_origins
    lloyds_origins = local.lloyds_origins_v4
    production_cidrs = [ local.cidrs.uksouth.aks.prod ]
    aks_cidrs = local.cidrs.uksouth.aks
}

module "uksouth_storage" {
    source = "./uksouth/storage"
    loganalytics_id = module.uksouth_loganalytics.id
}

module "uksouth_loganalytics" {
    source = "./uksouth/loganalytics"
    managed_identities = [
        module.uksouth_prod.managed_identities.kiroshi,
        module.uksouth_prod.managed_identities.snowstorm,
        module.uksouth_staging.managed_identities.snowstorm,
    ]
}

module "uksouth_subscription" {
    source = "./uksouth/subscription"
    subscription_id = {
        "uksouth_tools" = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009"
        "uksouth_dev" = "/subscriptions/6a36a6fd-e97c-42f2-88ff-2484d8165f53"
        "uksouth_staging" = "/subscriptions/e28b2912-1f6d-4ac7-9cd7-443d73876e10"
        "uksouth_sandbox" = "/subscriptions/64678f82-1a1b-4096-b7e9-41b1bdcdc024"
        "uksouth_perf" = "/subscriptions/c49c2fde-9e7d-41c6-ac61-f85f9fa51416"
        "uksouth_prod" = "/subscriptions/42706d13-8023-4b0c-b98a-1a562cb9ac40"
    }
    users = {
        chris_pressland = "48aca6b1-4d56-4a15-bc92-8aa9d97300df"
        nathan_read = "bba71e03-172e-4d07-8ee4-aad029d9031d"
        thenuja_viknarajah = "e69fd5a7-8b6c-4ac5-8df0-c88c77df0a12"
        navya_james = "35632f94-054f-41d1-9006-9e34fa04210f"
    }
}
