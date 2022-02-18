locals {
  subscriptions = {
    uk_core       = { id = "0add5c8e-50a6-4821-be0f-7a47c879b009" },
    uk_production = { id = "79560fde-5831-481d-8c3c-e812ef5046e5" },
    uk_preprod    = { id = "6e685cd8-73f6-4aa6-857c-04ed9b21d17d" },
    uk_staging    = { id = "457b0db5-6680-480f-9e77-2dafb06bd9dc" },
    uk_dev        = { id = "794aa787-ec6a-40dd-ba82-0ad64ed51639" },
    uk_sandbox    = { id = "957523d8-bbe2-4f68-8fae-95975157e91c" },
  }
  secure_origins = [
    "194.74.152.8/29", # Ascot Bink HQ
    "89.38.121.228/30", # London Bink Scrub Office
    "217.169.3.233/32", # cpressland@bink.com
    "81.2.99.144/29",   # cpressland@bink.com
    "${module.uksouth-wireguard.public_ip}/32",
  ]
  secure_origins_v6 = [
    "2001:8b0:b130:a52d::/64", # cpressland@bink.com
  ]
  managed_identities = {
    fakicorp          = { kv_access = "rw" },
    angelia           = { kv_access = "ro" },
    europa            = { kv_access = "rw" },
    harmonia          = { kv_access = "ro" },
    hermes            = { kv_access = "ro" },
    eos               = { kv_access = "ro" },
    polaris           = { kv_access = "ro" },
    event-horizon     = { kv_access = "ro" },
    metis             = { kv_access = "ro" },
    midas             = { kv_access = "ro" },
    azuregcpvaultsync = { kv_access = "ro" },
    pyqa              = { kv_access = "ro" },
    vela              = { kv_access = "ro" },
    zephyrus          = { kv_access = "ro" },
    carina            = { kv_access = "ro" },
    styx              = { kv_access = "ro" },
    cylops            = { kv_access = "ro" },
  }

  aad_group = {
    architecture          = "fb26c586-72a5-4fbc-b2b0-e1c28ef4fce1"
    qa                    = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d"
    cyber_sec             = "b56bc76d-1af5-4e44-8784-7ee7a44cc0c1"
    devops                = "aac28b59-8ac3-4443-bccc-3fb820165a08"
    backend               = "219194f6-b186-4146-9be7-34b731e19001"
    data_warehouse_admins = "8596acbd-b840-4124-9ec6-b6c0918ac247"
  }
  aad_user = {
    jo_raine          = "ac4c9b34-2e1b-4e46-bfca-2d64e1a3adbc"
    chris_sterritt    = "43ac5515-f32b-46a3-80c8-15a0a2ef24d5"
    mick_latham       = "343299d4-0a39-4109-adce-973ad29d0183"
    chris_latham      = "607482a3-07fa-4b24-8af0-5b84df6ca7c6"
    christian_prior   = "ae282437-d730-4342-8914-c936e8289cdc"
    charlie_bricknell = "2ef70efe-8675-419d-97cb-4775828383cd"
  }
  aad_apps = {
    confluence_macro = "ce918d9f-5641-4798-b1d5-bf31d234921a"
    kubernetes_sso   = "ed09bbbc-7b4d-4f2e-a657-3f0c7b3335c7"
  }

  prod_cluster_ingress_subdomains = [ "api", "policies", "link", "data", "api2-docs" ]
}

terraform {
  backend "azurerm" {
    storage_account_name = "binkitops"
    container_name       = "terraform"
    key                  = "azure.tfstate"
    access_key           = "bRtDCEojOLE122v5glr8g+kyxLytWMp/OSPsjqmiXr972xPOGNRwXOBFPCCze1Ge5dk+imhW+ZdKeOFahNVEFg=="
  }

  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.96.0"
    }
    chef = {
      source = "terrycain/chef"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

data "terraform_remote_state" "uksouth-common" {
  backend = "azurerm"

  config = {
    storage_account_name = "binkitops"
    container_name       = "terraform"
    key                  = "uksouth-common.tfstate"
    access_key           = "bRtDCEojOLE122v5glr8g+kyxLytWMp/OSPsjqmiXr972xPOGNRwXOBFPCCze1Ge5dk+imhW+ZdKeOFahNVEFg=="
  }
}

data "azurerm_subscription" "primary" {}

module "uksouth-core" {
  source = "./uksouth/core"
}

module "uksouth-bastion" {
  source = "./uksouth/bastion"

  firewall_route_ip          = module.uksouth-firewall.firewall_ip
  firewall_vnet_id           = module.uksouth-firewall.vnet_id
  private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
  loganalytics_id            = module.uksouth_loganalytics.loganalytics_core_id
}

module "uksouth-gitlab" {
  source = "./uksouth/gitlab"

  firewall_route_ip          = module.uksouth-firewall.firewall_ip
  firewall_vnet_id           = module.uksouth-firewall.vnet_id
  private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
  loganalytics_id            = module.uksouth_loganalytics.loganalytics_core_id
}

module "uksouth-dns" {
  source = "./uksouth/dns"
}

module "uksouth-alerts" {
  source = "./uksouth/alerts"
}

module "uksouth-eventhubs" {
  source = "./uksouth/eventhubs"
}

module "uksouth-chef" {
  source = "./uksouth/chef"

  private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
  loganalytics_id            = module.uksouth_loganalytics.loganalytics_core_id
}

module "uksouth-frontdoor" {
  source = "./uksouth/frontdoor"

  secure_origins    = local.secure_origins
  secure_origins_v6 = local.secure_origins_v6
  loganalytics_id   = module.uksouth_loganalytics.loganalytics_core_id
}

module "uksouth-firewall" {
  source = "./uksouth/firewall"

  bastion_ip_address = module.uksouth-bastion.ip_address
  sftp_ip_address    = module.uksouth-sftp.ip_address
  loganalytics_id    = module.uksouth_loganalytics.loganalytics_core_id
  secure_origins     = local.secure_origins
}

# module "uksouth-sandbox" {
#     source = "./uksouth/sandbox"

#     common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
#     common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
#     private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
#     private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
# }

module "uksouth-storage" {
  source          = "./uksouth/storage"
  loganalytics_id = module.uksouth_loganalytics.loganalytics_core_id
}

module "uksouth-elasticsearch" {
  source = "./uksouth/elasticsearch"

  private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
  loganalytics_id            = module.uksouth_loganalytics.loganalytics_core_id
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
          "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4hWtuYpNwLKB0YEHwxEdtib0oxDPWVfW9y45eJhfvcjQA8/e8GHHRCSIUsWEcmjEZE1ZHc1MX09xS1HteExxjhOtMJ1x5qS0ye0rbxGujkpxdyfuTfyU+MRIQI7r4/Gt1bsrEJyULz287mfZK+IePGRun9sbRxHcVqgTXnHy/7PdKUyzykLCvTcnCUT8pdRU8GNqAHwtNojMJ8Qa6g3FP6Q9rlYCMZ7gA+dJvkm6oxgkpss3nbi4ZiDfZVbsUG49k0TP6qBC0r404eJjKfES1PZ2RveFuwAw4rur0ctUwiEYZtbenv4EzaYNtIpFg569r5ubuGfNNu/LXnOS8CzV2Ol1qIq0wCFkS3HIvGzU8wp0Fv+7RYiJclNKnnxDQ2w/4batinNgyCqhenEIZSKCPfWDipQn4CEEGqjpKqGeI2kAJgEDDUXjAThUDJHG6ill0EXxvpw2Ae0Ua8vuUgwGqw5x8gwWvyHPRBTCgCekVofRwZHVtMzP72rD71zXkkhnst8EfVb6C/J629qeAl2kkQLUWReal5NTuTi4ZpTb4UFge97kjwtoYUncfU0aqepYn/h7nJI3CXXDkhz5oK20oo0nxpYmIkhBAHKN1OsyyIpb0cOZUgoqWlvbvKJjoaaKbcXiyWK+4AIAOkj0x7oCGGFGeTIhISvQp9WPIV4IsIw==\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqui3ya3xyECnjnlpb4nLq0ibDgjh/DGjf9h2lsiuVOXbtXm3Vs0D7qKd4M2Z+NaRGoaqdUTjeAbhIFApJoxnk7FetNUYc89qC85pjsXv9VAZZs1PcxmdgL5lVu6S5vs1shozJIC3eejRReSuvLGrOtt/EvMmzUHhnSNZqwomIhnK1sSUiv7qrB/Yh7n7kmxuEixDUVnia1vSvNHFq+prf9wrH1ChfuCME7IxUNiOOupCwYWjJelsizhdpqwsYFuPg92J4ClPCzzeRyRkg5XFYSuT6lq3I/3a23ypgnN/sVVTH7DYx8f9GR4jmQwcR+kWvZiOMEb415A7LHbhf5PaJuIhD83ixCPbomk0rzCPv2J1ayWxyDW38S5jAWa8fvkTy1Yk9tVqu8NEr9S+l5qzkmdDiUnL5V22zxSGdIf2hOlf9tI/Cy5jN0ESQHuODubpmYCXt1zK5mKwLgLz5AUi9bz7brf5dFcAzzQK/6VfSijulkKDx4BqNF9cDiTEDQ7hDtPjtYnzYQ7yA9FpY165bAy7mA2YYUr0Z4huYRTW3bacX0cGwvgCyOqZkQ33hKfRnFTD+32PD9EoVdUCRvT7kkODpu1k40ZSqqc1Pkgk9EGGI5gpkgUXQzR7CAv4JPhe0vrUKEk3rSi6b4EJ4+gqmb2fLlzFXqgOuMR1bo1n64w=="
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
        { # Used to test the SFTP functionality of the Barclays SFTP Notifications rubbish
          "name" : "binktest_dev_hermes_barclays",
          "id" : 4506,
          "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCuqR1EarVpxolYA8/jncHSZJ2c63clp+ygYn5M4i2N5gPH2L3JaDme8ZJ+8k7soq1QgxJMDHZ9yYDFCQpCg/VeLPY4Ve6FbOMOyM3vEkesls2KmkKqer8uwBRUufqH4NlTmKT2jZZiP65ODyo8Ssv3tQF0vaGiatg030XjhPZDmtNIFWV1VEFgclSzhFvugrY+HcckyJiUoWc1w7yYUzhnJb+PRhj5BaohbffD1VEQfgmjEDnaryFbdltaEa4Oe+tu0l6JVVtW7Z5nMuKBzEgr37PCpRyJPPtromVDK8gFZ+SFyEjiOpWcMcC2V3J7m1jlGNj8Snyuaz1N6nHOjqx"
        },
      ]
    }
  }

  private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host

  peers = {
    firewall = {
      vnet_id             = module.uksouth-firewall.vnet_id
      vnet_name           = module.uksouth-firewall.vnet_name
      resource_group_name = module.uksouth-firewall.resource_group_name
    }
  }
  loganalytics_id = module.uksouth_loganalytics.loganalytics_core_id
}

module "uksouth_loganalytics" {
    source = "./uksouth/loganalytics"
}

module "uksouth-redscan" {
  source          = "./uksouth/redscan"
  bink_sh         = module.uksouth-dns.bink-sh
  dns_link        = module.uksouth-dns.uksouth-bink-host
  secure_origins  = local.secure_origins
  loganalytics_id = module.uksouth_loganalytics.loganalytics_core_id
}

module "uksouth-wireguard" {
  source          = "./uksouth/wireguard"
  secure_origins  = local.secure_origins
  loganalytics_id = module.uksouth_loganalytics.loganalytics_core_id
}

module "uksouth_wordpress" {
  source          = "./uksouth/wordpress"
  secure_origins  = local.secure_origins
  dns_zone        = module.uksouth-dns.public_dns
  loganalytics_id = module.uksouth_loganalytics.loganalytics_core_id
}
