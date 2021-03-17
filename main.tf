locals {
    subscriptions = {
        uk_core = { id = "0add5c8e-50a6-4821-be0f-7a47c879b009" },
        uk_production = { id = "79560fde-5831-481d-8c3c-e812ef5046e5" },
        uk_preprod = { id = "6e685cd8-73f6-4aa6-857c-04ed9b21d17d" },
        uk_staging = { id = "457b0db5-6680-480f-9e77-2dafb06bd9dc" },
        uk_dev = { id = "794aa787-ec6a-40dd-ba82-0ad64ed51639" },
        uk_sandbox = { id = "957523d8-bbe2-4f68-8fae-95975157e91c" },
    }
    secure_origins = [
        "194.74.152.11/32", # Ascot Bink HQ
        "217.169.3.233/32", # cpressland@bink.com
        "81.2.99.144/29",   # cpressland@bink.com
        "82.20.241.99/32",  # twinchester@bink.com
        "86.5.50.186/32",   # tcain@bink.com
        "${module.uksouth-wireguard.public_ip}/32",
    ]
    secure_origins_v6 = [
        "2001:8b0:b130:a52d::/64", # cpressland@bink.com
    ]
    developer_ips = [
        "82.22.136.116/32",  # ml@bink.com
        "82.14.237.4/32",    # cl@bink.com
        "92.232.43.170/32",  # akhan@bink.com
        "92.233.6.15/32",    # kaziz@bink.com
        "86.150.164.212/32", # sperrygrove@bink.com
        "92.0.40.250/32",    # njames@bink.com
    ]
}

terraform {
    backend "azurerm" {
        storage_account_name = "binkitops"
        container_name = "terraform"
        key = "azure.tfstate"
        access_key = "bRtDCEojOLE122v5glr8g+kyxLytWMp/OSPsjqmiXr972xPOGNRwXOBFPCCze1Ge5dk+imhW+ZdKeOFahNVEFg=="
    }

    required_version = ">= 0.13"

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "2.51.0"
        }
        chef = {
            source = "terrycain/chef"
        }
        random = {
            source = "hashicorp/random"
        }
        checkly = {
            source = "checkly/checkly"
        }
    }
}

data "terraform_remote_state" "uksouth-common" {
    backend = "azurerm"

    config = {
        storage_account_name = "binkitops"
        container_name = "terraform"
        key = "uksouth-common.tfstate"
        access_key = "bRtDCEojOLE122v5glr8g+kyxLytWMp/OSPsjqmiXr972xPOGNRwXOBFPCCze1Ge5dk+imhW+ZdKeOFahNVEFg=="
    }
}

data "azurerm_subscription" "primary" {}

module "uksouth-core" {
    source = "./uksouth/core"
}

module "uksouth-bastion" {
    source = "./uksouth/bastion"

    firewall_route_ip = module.uksouth-firewall.firewall_ip
    firewall_vnet_id = module.uksouth-firewall.vnet_id
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh

}

module "uksouth-gitlab" {
    source = "./uksouth/gitlab"

    firewall_route_ip = module.uksouth-firewall.firewall_ip
    firewall_vnet_id = module.uksouth-firewall.vnet_id
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-dns" {
    source = "./uksouth/dns"
}

module "uksouth-alerts" {
    source = "./uksouth/alerts"
}

# Blocked until https://github.com/terraform-providers/terraform-provider-azuread/issues/173
# module "uksouth-azuread-apps" {
#     source = "./uksouth/azuread_applications"
# }

module "uksouth-eventhubs" {
    source = "./uksouth/eventhubs"
}

module "uksouth-chef" {
    source = "./uksouth/chef"

    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-frontdoor" {
    source = "./uksouth/frontdoor"

    secure_origins = local.secure_origins
    secure_origins_v6 = local.secure_origins_v6
    backends = {
        "staging" : [
            module.uksouth_staging_cluster_0.frontdoor_backend_pool
        ],
        "staging-policies" : [
            module.uksouth_staging_cluster_0.frontdoor_backend_policies_pool
        ],
        "sit" : [
            module.uksouth_sit_cluster_0.frontdoor_backend_pool
        ],
        "oat" : [
            module.uksouth_oat_cluster_0.frontdoor_backend_pool
        ],
        "prod" : [
            module.uksouth_prod_cluster_0.frontdoor_backend_pool
        ],
        "prod-policies" : [
            module.uksouth_prod_cluster_0.frontdoor_backend_policies_pool
        ],
        "preprod" : [
            module.uksouth_preprod_cluster_1.frontdoor_backend_pool
        ],
        "dev" : [
            module.uksouth_dev_cluster_0.frontdoor_backend_pool
        ],
        "performance" : [
            module.uksouth_performance_cluster_0.frontdoor_backend_pool
        ],
    }
}

module "uksouth-firewall" {
    source = "./uksouth/firewall"

    sentry_vnet_id = module.uksouth-sentry.vnet_id
    tableau_vnet_id = module.uksouth-tableau.vnet_id
    sentry_ip_address = module.uksouth-sentry.ip_address
    bastion_ip_address = module.uksouth-bastion.ip_address
    sftp_ip_address = module.uksouth-sftp.ip_address
    tableau_ip_address = module.uksouth-tableau.ip_address
    secure_origins = local.secure_origins
    developer_ips = local.developer_ips
}

# module "uksouth-sandbox" {
#     source = "./uksouth/sandbox"

#     common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
#     common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
#     private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
#     private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
# }

module "uksouth-storage" {
    source = "./uksouth/storage"
}

module "uksouth-tableau" {
    source = "./uksouth/tableau"

    worker_subnet = "/subscriptions/79560fde-5831-481d-8c3c-e812ef5046e5/resourceGroups/uksouth-prod-k0/providers/Microsoft.Network/virtualNetworks/prod0-vnet/subnets/worker"
    firewall_vnet_id = module.uksouth-firewall.vnet_id
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
    wireguard_ip = module.uksouth-wireguard.public_ip
}

module "uksouth-sentry" {
    source = "./uksouth/sentry"

    firewall_vnet_id = module.uksouth-firewall.vnet_id
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-elasticsearch" {
    source = "./uksouth/elasticsearch"

    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-sftp" {
    source = "./uksouth/sftp"

    config = {
        "ssh" : {
            "ciphers" : "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr",
            "macs" : "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-sha1,hmac-sha1-96,hmac-md5",
            "kexalgorithms" : "curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1",
        },
        "users" : {
            "sftp" : [
                {
                    "name" : "harveynichols",
                    "id" : 4000,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEApo4pf1NWLWrcmRWqLvFKOvkzJKDyo8QkN/pil60x4YPs/j+8JUiO1UI9TeP4YSJ9C3nyFNkjqc0jorI5EnVUPdVCGRPweZCgr4Di4eu/2KgYobO9DzvRoBvZAzxIR3dlJDsnOa27FscQ6iZXWdgCvJcTPQaEot/8eKDifZ+eU3Rh2mpVCykiNH4qeYPUTJDws+aC1PfTQQ8bmcN8IWxcG+dVjkKzlM/NJ0lzsJiOQGRJc0ZuC66D8UwJXF0UEzsteWge9DDL394t9mHl5DFhhuLsZ+laNsqVstdppwFk+S9Hd63wy4Yrdu3Wz1obgXcBrdROESTyiZ5o4kaRwf48DQ==",
                    "upload" : {
                        "conn_string" : module.uksouth_prod_environment.storage_accounts.binkuksouthprod,
                        "container" : "harmonia-imports",
                        "slug" : "scheme/harvey-nichols",
                    }
                },
                {
                    "name" : "iceland",
                    "id" : 4001,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlR8IrClW5vyU3utv+LTshjt49FWxdHnogNj1JesWvQZPla0nFze28Ohup3EPWLZUbVL4z3ay8PJeotszIEDHKc5K8P2/cwytdopOpdvdWJfxZcLzIIrKSMXjc+uXWLA+jvav9JIewEda/SsiM2ChYmR6BtpQirUtupcrbXXPXsjWoZ1BZdKZ6EmVT3uq1bGvMUZgr77QThtbcfR4x9B/3eVJSK5r1H8baohnkQx0cEcCt9KSkjU3gw5RXGKqJXAci+nR/ieCNw5znqKHaIEvsV06UKxqL9UYjuXdLI1bA24R3IKxhb4vrklTt0paisXPljp4YekDRAJ7j9BpgSve3w==",
                    "upload" : {
                        "conn_string" : module.uksouth_prod_environment.storage_accounts.binkuksouthprod,
                        "container" : "harmonia-imports",
                        "slug" : "scheme/iceland",
                    }
                },
                {
                    "name" : "xcm-fatface",
                    "id" : 4002,
                    "ssh_key" : "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZ/o58SV1LaKVqocPR88huiHKdmnx53elrvwfPqjFRu",
                    "upload" : {
                        "conn_string" : module.uksouth_prod_environment.storage_accounts.binkuksouthprod,
                        "container" : "harmonia-imports",
                        "slug" : "scheme/fatface",
                    }
                },
                {
                    "name" : "binktest_prod",
                    "id" : 4500,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4hWtuYpNwLKB0YEHwxEdtib0oxDPWVfW9y45eJhfvcjQA8/e8GHHRCSIUsWEcmjEZE1ZHc1MX09xS1HteExxjhOtMJ1x5qS0ye0rbxGujkpxdyfuTfyU+MRIQI7r4/Gt1bsrEJyULz287mfZK+IePGRun9sbRxHcVqgTXnHy/7PdKUyzykLCvTcnCUT8pdRU8GNqAHwtNojMJ8Qa6g3FP6Q9rlYCMZ7gA+dJvkm6oxgkpss3nbi4ZiDfZVbsUG49k0TP6qBC0r404eJjKfES1PZ2RveFuwAw4rur0ctUwiEYZtbenv4EzaYNtIpFg569r5ubuGfNNu/LXnOS8CzV2Ol1qIq0wCFkS3HIvGzU8wp0Fv+7RYiJclNKnnxDQ2w/4batinNgyCqhenEIZSKCPfWDipQn4CEEGqjpKqGeI2kAJgEDDUXjAThUDJHG6ill0EXxvpw2Ae0Ua8vuUgwGqw5x8gwWvyHPRBTCgCekVofRwZHVtMzP72rD71zXkkhnst8EfVb6C/J629qeAl2kkQLUWReal5NTuTi4ZpTb4UFge97kjwtoYUncfU0aqepYn/h7nJI3CXXDkhz5oK20oo0nxpYmIkhBAHKN1OsyyIpb0cOZUgoqWlvbvKJjoaaKbcXiyWK+4AIAOkj0x7oCGGFGeTIhISvQp9WPIV4IsIw=="
                },
                {
                    "name" : "binktest_preprod",
                    "id" : 4501,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4hWtuYpNwLKB0YEHwxEdtib0oxDPWVfW9y45eJhfvcjQA8/e8GHHRCSIUsWEcmjEZE1ZHc1MX09xS1HteExxjhOtMJ1x5qS0ye0rbxGujkpxdyfuTfyU+MRIQI7r4/Gt1bsrEJyULz287mfZK+IePGRun9sbRxHcVqgTXnHy/7PdKUyzykLCvTcnCUT8pdRU8GNqAHwtNojMJ8Qa6g3FP6Q9rlYCMZ7gA+dJvkm6oxgkpss3nbi4ZiDfZVbsUG49k0TP6qBC0r404eJjKfES1PZ2RveFuwAw4rur0ctUwiEYZtbenv4EzaYNtIpFg569r5ubuGfNNu/LXnOS8CzV2Ol1qIq0wCFkS3HIvGzU8wp0Fv+7RYiJclNKnnxDQ2w/4batinNgyCqhenEIZSKCPfWDipQn4CEEGqjpKqGeI2kAJgEDDUXjAThUDJHG6ill0EXxvpw2Ae0Ua8vuUgwGqw5x8gwWvyHPRBTCgCekVofRwZHVtMzP72rD71zXkkhnst8EfVb6C/J629qeAl2kkQLUWReal5NTuTi4ZpTb4UFge97kjwtoYUncfU0aqepYn/h7nJI3CXXDkhz5oK20oo0nxpYmIkhBAHKN1OsyyIpb0cOZUgoqWlvbvKJjoaaKbcXiyWK+4AIAOkj0x7oCGGFGeTIhISvQp9WPIV4IsIw=="
                },
                {
                    "name" : "binktest_staging",
                    "id" : 4502,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4hWtuYpNwLKB0YEHwxEdtib0oxDPWVfW9y45eJhfvcjQA8/e8GHHRCSIUsWEcmjEZE1ZHc1MX09xS1HteExxjhOtMJ1x5qS0ye0rbxGujkpxdyfuTfyU+MRIQI7r4/Gt1bsrEJyULz287mfZK+IePGRun9sbRxHcVqgTXnHy/7PdKUyzykLCvTcnCUT8pdRU8GNqAHwtNojMJ8Qa6g3FP6Q9rlYCMZ7gA+dJvkm6oxgkpss3nbi4ZiDfZVbsUG49k0TP6qBC0r404eJjKfES1PZ2RveFuwAw4rur0ctUwiEYZtbenv4EzaYNtIpFg569r5ubuGfNNu/LXnOS8CzV2Ol1qIq0wCFkS3HIvGzU8wp0Fv+7RYiJclNKnnxDQ2w/4batinNgyCqhenEIZSKCPfWDipQn4CEEGqjpKqGeI2kAJgEDDUXjAThUDJHG6ill0EXxvpw2Ae0Ua8vuUgwGqw5x8gwWvyHPRBTCgCekVofRwZHVtMzP72rD71zXkkhnst8EfVb6C/J629qeAl2kkQLUWReal5NTuTi4ZpTb4UFge97kjwtoYUncfU0aqepYn/h7nJI3CXXDkhz5oK20oo0nxpYmIkhBAHKN1OsyyIpb0cOZUgoqWlvbvKJjoaaKbcXiyWK+4AIAOkj0x7oCGGFGeTIhISvQp9WPIV4IsIw=="
                },
                {
                    "name" : "binktest_dev",
                    "id" : 4503,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4hWtuYpNwLKB0YEHwxEdtib0oxDPWVfW9y45eJhfvcjQA8/e8GHHRCSIUsWEcmjEZE1ZHc1MX09xS1HteExxjhOtMJ1x5qS0ye0rbxGujkpxdyfuTfyU+MRIQI7r4/Gt1bsrEJyULz287mfZK+IePGRun9sbRxHcVqgTXnHy/7PdKUyzykLCvTcnCUT8pdRU8GNqAHwtNojMJ8Qa6g3FP6Q9rlYCMZ7gA+dJvkm6oxgkpss3nbi4ZiDfZVbsUG49k0TP6qBC0r404eJjKfES1PZ2RveFuwAw4rur0ctUwiEYZtbenv4EzaYNtIpFg569r5ubuGfNNu/LXnOS8CzV2Ol1qIq0wCFkS3HIvGzU8wp0Fv+7RYiJclNKnnxDQ2w/4batinNgyCqhenEIZSKCPfWDipQn4CEEGqjpKqGeI2kAJgEDDUXjAThUDJHG6ill0EXxvpw2Ae0Ua8vuUgwGqw5x8gwWvyHPRBTCgCekVofRwZHVtMzP72rD71zXkkhnst8EfVb6C/J629qeAl2kkQLUWReal5NTuTi4ZpTb4UFge97kjwtoYUncfU0aqepYn/h7nJI3CXXDkhz5oK20oo0nxpYmIkhBAHKN1OsyyIpb0cOZUgoqWlvbvKJjoaaKbcXiyWK+4AIAOkj0x7oCGGFGeTIhISvQp9WPIV4IsIw=="
                },
                {
                    "name" : "tom_winchester_sftp",
                    "id" : 4504,
                    "ssh_key" : "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6a2KLI7tsQao5tEoeYVZG//erLryOxo/qV/BH6VEf3"
                },
                {
                    "name" : "binktest_perf",
                    "id" : 4505,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4hWtuYpNwLKB0YEHwxEdtib0oxDPWVfW9y45eJhfvcjQA8/e8GHHRCSIUsWEcmjEZE1ZHc1MX09xS1HteExxjhOtMJ1x5qS0ye0rbxGujkpxdyfuTfyU+MRIQI7r4/Gt1bsrEJyULz287mfZK+IePGRun9sbRxHcVqgTXnHy/7PdKUyzykLCvTcnCUT8pdRU8GNqAHwtNojMJ8Qa6g3FP6Q9rlYCMZ7gA+dJvkm6oxgkpss3nbi4ZiDfZVbsUG49k0TP6qBC0r404eJjKfES1PZ2RveFuwAw4rur0ctUwiEYZtbenv4EzaYNtIpFg569r5ubuGfNNu/LXnOS8CzV2Ol1qIq0wCFkS3HIvGzU8wp0Fv+7RYiJclNKnnxDQ2w/4batinNgyCqhenEIZSKCPfWDipQn4CEEGqjpKqGeI2kAJgEDDUXjAThUDJHG6ill0EXxvpw2Ae0Ua8vuUgwGqw5x8gwWvyHPRBTCgCekVofRwZHVtMzP72rD71zXkkhnst8EfVb6C/J629qeAl2kkQLUWReal5NTuTi4ZpTb4UFge97kjwtoYUncfU0aqepYn/h7nJI3CXXDkhz5oK20oo0nxpYmIkhBAHKN1OsyyIpb0cOZUgoqWlvbvKJjoaaKbcXiyWK+4AIAOkj0x7oCGGFGeTIhISvQp9WPIV4IsIw=="
                },
            ]
        }
    }

    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host

    peers = {
        firewall = {
            vnet_id = module.uksouth-firewall.vnet_id
            vnet_name = module.uksouth-firewall.vnet_name
            resource_group_name = module.uksouth-firewall.resource_group_name
        }
    }
}

module "uksouth-mastercard" {
    source = "./uksouth/mastercard"
    secure_origins = local.secure_origins
}

module "uksouth-redscan" {
    source = "./uksouth/redscan"
    bink_sh = module.uksouth-dns.bink-sh
    dns_link = module.uksouth-dns.uksouth-bink-host
    secure_origins = local.secure_origins
}

module "uksouth-wireguard" {
    source = "./uksouth/wireguard"
    secure_origins = local.secure_origins
}
