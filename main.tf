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
        "194.74.152.11/32", # Ascot Secondary - BT
        "80.87.29.254/32",  # London Primary - Scrub Office
        "217.169.3.233/32",  # cpressland@bink.com
        "81.2.99.144/29",  # cpressland@bink.com
        "31.125.46.20/32",  # nread@bink.com
        "81.133.125.233/32", # Thenuja, not static, will rotate.
        "20.49.208.61/32", # module.uksouth_vpn.ip_addresses.ipv4,
    ]
    secure_origins_v6 = [
        "2001:8b0:b130::/48", # cpressland@bink.com
        "2a05:87c1:17c::/48", # Ascot Primary - Giganet
        "2a00:23a8:50:1400::/64", # Thenuja, should be static unless BT implemented IPv6 improperly
        "2603:1020:702:3::3a/128", # module.uksouth_vpn.ip_addresses.ipv6,
    ]
    lloyds_origins_v4 = [
        "141.92.129.40/29", # Peterborough
        "141.92.67.40/29", # Horizon
    ]
    entra_users = { for k, v in data.azuread_users.all.users : v.user_principal_name => v }
    entra_groups = {
        for group_name in distinct(data.azuread_groups.all.display_names) : group_name =>
            data.azuread_groups.all.object_ids[index(data.azuread_groups.all.display_names, group_name)]
    }
    aad_user = {
        terraform = "4869640a-3727-4496-a8eb-f7fae0872410"
    }
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
            version = "3.84.0"
        }
        azuread = {
            source  = "hashicorp/azuread"
            version = "2.46.0"
        }
        cloudamqp = {
            source = "cloudamqp/cloudamqp"
        }
        random = {
            source = "hashicorp/random"
        }
    }
}

data "azuread_users" "all" {
    return_all = true
}

data "azuread_groups" "all" {
    return_all = true
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
    iam = []
}

module "uksouth_tailscale" {
    source = "./tailscale"
    common = {
        secure_origins_v4 = local.secure_origins
        secure_origins_v6 = local.secure_origins_v6
    }
    dns = {
        record = "tailscale.gb"
        resource_group_name = module.uksouth_dns.resource_group_name
        zone_name = module.uksouth_dns.bink_com_zone
    }
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

module "uksouth_dns" {
    source = "./uksouth/dns"
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
          tailscale = [module.uksouth_tailscale.ip_addresses.ipv4, module.uksouth_tailscale.ip_addresses.ipv6]
        }
        key_vault = {
            admin_object_ids = {
                "devops" = local.entra_groups["DevOps"]
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
    iam = [
        local.entra_groups["Architecture"],
        local.entra_groups["Backend"],
        local.entra_groups["Service"],
        local.entra_users["ah@bink.com"].object_id,
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
