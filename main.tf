provider "azurerm" {
    version = "~> 2.2.0"
    subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
    client_id = "98e2ee67-a52d-40fc-9b39-155887530a7b"
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "chef" {
    server_url = "https://chef.uksouth.bink.sh:4444/organizations/bink/"

    client_name = chomp(file("~/.chef/username"))
    key_material = file("~/.chef/user.pem")
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

data "terraform_remote_state" "uksouth-common" {
    backend = "azurerm"

    config = {
        resource_group_name = "storage"
        storage_account_name = "binkitops"
        container_name = "terraform"
        key = "uksouth-common.tfstate"
    }
}

module "uksouth-bastion" {
    source = "./uksouth/bastion"

    firewall_route_ip = module.uksouth-firewall.firewall_ip
    firewall_vnet_id = module.uksouth-firewall.vnet_id
}

module "uksouth-chef" {
    source = "./uksouth/chef"
}

module "uksouth-frontdoor" {
    source = "./uksouth/frontdoor"
}

module "uksouth-dev" {
    source = "./uksouth/dev"

    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
}

module "uksouth-firewall" {
    source = "./uksouth/firewall"

    wireguard_vnet_id = module.uksouth-wireguard.vnet_id
    sentry_vnet_id = module.uksouth-sentry.vnet_id
    tableau_vnet_id = module.uksouth-tableau.vnet_id
    tools_vnet_id = module.uksouth-tools.vnet_id

    wireguard_ip_address = module.uksouth-wireguard.ip_address
    sentry_ip_address = module.uksouth-sentry.ip_address
    bastion_ip_address = module.uksouth-bastion.ip_address
    tableau_ip_address = module.uksouth-tableau.ip_address
}

module "uksouth-wireguard" {
    source = "./uksouth/wireguard"
    firewall_vnet_id = module.uksouth-firewall.vnet_id
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
    worker_subnet = module.uksouth-prod.subnet_ids.worker
    firewall_vnet_id = module.uksouth-firewall.vnet_id
}

module "uksouth-prod" {
    source = "./uksouth/prod"
}

module "uksouth-preprod" {
    source = "./uksouth/preprod"
    worker_subnet = module.uksouth-prod.subnet_ids.worker
}

module "uksouth-sentry" {
    source = "./uksouth/sentry"
    firewall_vnet_id = module.uksouth-firewall.vnet_id
}

module "uksouth-tools" {
    source = "./uksouth/tools"
    gitops_repo = "git@git.bink.com:DevOps/gitops/tools.k8s.uksouth.bink.sh.git"
    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
}

module "ukwest-monitoring" {
    source = "./ukwest/monitoring"
}

