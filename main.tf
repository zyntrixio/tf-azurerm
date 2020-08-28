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
        "81.2.99.144/29", # cpressland@bink.com
        "82.21.89.96/32", # twinchester@bink.com
        "82.24.92.107/32", # tcain@bink.com
    ]
    developer_ips = [
        "82.22.136.116/32", # ml@bink.com
        "82.14.237.4/32", # cl@bink.com
        "92.232.43.170/32", # akhan@bink.com
        "92.233.6.15/32", # kaziz@bink.com
        "86.150.164.212/32", # sperrygrove@bink.com
    ]
}

terraform {
    backend "azurerm" {
        resource_group_name = "storage"
        storage_account_name = "binkitops"
        container_name = "terraform"
        key = "azure.tfstate"
    }

    required_version = ">= 0.12"
}

data "terraform_remote_state" "uksouth-common" {
    backend = "azurerm"

    config = {
        resource_group_name = "storage"
        storage_account_name = "binkitops"
        container_name = "terraform"
        key = "uksouth-common.tfstate"
    }
}

data "azurerm_subscription" "primary" {}

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

    backends = {
        "prod" : [
            module.uksouth_prod_cluster_0.frontdoor_backend_pool
        ],
        "prod-policies" : [
            module.uksouth_prod_cluster_0.frontdoor_backend_policies_pool
        ]
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

module "uksouth-dev" {
    source = "./uksouth/dev"

    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-firewall" {
    source = "./uksouth/firewall"

    sentry_vnet_id = module.uksouth-sentry.vnet_id
    tableau_vnet_id = module.uksouth-tableau.vnet_id
    tools_vnet_id = module.uksouth-tools.vnet_id
    sentry_ip_address = module.uksouth-sentry.ip_address
    bastion_ip_address = module.uksouth-bastion.ip_address
    tableau_ip_address = module.uksouth-tableau.ip_address
    secure_origins = local.secure_origins
    developer_ips = local.developer_ips
}

module "uksouth-sandbox" {
    source = "./uksouth/sandbox"

    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-staging" {
    source = "./uksouth/staging"

    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-storage" {
    source = "./uksouth/storage"
}

module "uksouth-tableau" {
    source = "./uksouth/tableau"

    worker_subnet = "/subscriptions/79560fde-5831-481d-8c3c-e812ef5046e5/resourceGroups/uksouth-prod-k0/providers/Microsoft.Network/virtualNetworks/prod0-vnet/subnets/worker"
    firewall_vnet_id = module.uksouth-firewall.vnet_id
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-sentry" {
    source = "./uksouth/sentry"

    firewall_vnet_id = module.uksouth-firewall.vnet_id
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-tools" {
    source = "./uksouth/tools"

    gitops_repo = "git@git.bink.com:DevOps/gitops/tools.k8s.uksouth.bink.sh.git"
    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-elasticsearch" {
    source = "./uksouth/elasticsearch"

    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-mastercard" {
    source = "./uksouth/mastercard"
}
