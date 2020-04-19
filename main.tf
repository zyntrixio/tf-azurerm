provider "azurerm" {
    version = "~> 2.2.0"
    subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
    client_id = "98e2ee67-a52d-40fc-9b39-155887530a7b"
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "random" {
    version = "~> 2.2"
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

module "uksouth-bastion" {
    source = "./uksouth/bastion"
}

module "uksouth-chef" {
    source = "./uksouth/chef"
}

module "uksouth-frontdoor" {
    source = "./uksouth/frontdoor"
}

module "uksouth-dev" {
    source = "./uksouth/dev"
}

module "uksouth-firewall" {
    source = "./uksouth/firewall"
    sentry_vnet_id = module.uksouth-sentry.vnet_id
    sentry_ip_address = module.uksouth-sentry.ip_address
}

module "uksouth-vault" {
    source = "./uksouth/vault"
}

module "uksouth-monitoring" {
    source = "./uksouth/monitoring"
}

module "uksouth-sandbox" {
    source = "./uksouth/sandbox"
}

module "uksouth-staging" {
    source = "./uksouth/staging"
}

module "uksouth-storage" {
    source = "./uksouth/storage"
}

module "uksouth-tableau" {
    source = "./uksouth/tableau"
}

module "uksouth-prod" {
    source = "./uksouth/prod"
}

module "uksouth-sentry" {
    source = "./uksouth/sentry"
    firewall_vnet_id = module.uksouth-firewall.vnet_id
}

module "ukwest-monitoring" {
    source = "./ukwest/monitoring"
}
