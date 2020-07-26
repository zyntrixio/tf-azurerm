provider "azurerm" {
    version = "~> 2.17.0"
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

data "azurerm_subscription" "primary" {}

resource "azurerm_role_assignment" "devops" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Owner"
    principal_id = "aac28b59-8ac3-4443-bccc-3fb820165a08"
}

resource "azurerm_role_assignment" "backend" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Reader"
    principal_id = "219194f6-b186-4146-9be7-34b731e19001"
}

resource "azurerm_role_assignment" "qa" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Reader"
    principal_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d"
}

resource "azurerm_role_assignment" "architecture" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Reader"
    principal_id = "fb26c586-72a5-4fbc-b2b0-e1c28ef4fce1"
}

resource "azurerm_role_assignment" "john_rouffas" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Reader"
    principal_id = "d04bb55a-9ca8-4115-9b00-54ec0d61a64c"
}

resource "azurerm_role_assignment" "jo_raine" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Billing Reader"
    principal_id = "ac4c9b34-2e1b-4e46-bfca-2d64e1a3adbc"
}

resource "azurerm_role_assignment" "kubernetes_sso" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Contributor"
    principal_id = "ed09bbbc-7b4d-4f2e-a657-3f0c7b3335c7"
}

resource "azurerm_role_assignment" "azure_frontdoor" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Contributor"
    principal_id = "f0222751-c786-45ca-bbfb-66037b63c4ac"
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
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-monitoring" {
    source = "./uksouth/monitoring"

    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
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

    worker_subnet = module.uksouth-prod.subnet_ids.worker
    firewall_vnet_id = module.uksouth-firewall.vnet_id
    vpn_subnet_id = module.uksouth-wireguard.subnet_id
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-prod" {
    source = "./uksouth/prod"

    vpn_subnet_id = module.uksouth-wireguard.subnet_id
    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity
    private_dns_link_bink_host = module.uksouth-dns.uksouth-bink-host
    private_dns_link_bink_sh = module.uksouth-dns.uksouth-bink-sh
}

module "uksouth-preprod" {
    source = "./uksouth/preprod"
    worker_subnet = module.uksouth-prod.subnet_ids.worker
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
