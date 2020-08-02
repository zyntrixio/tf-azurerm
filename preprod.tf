module "uksouth_preprod_environment" {
    source = "./modules/environment"
    providers = {
        azurerm = azurerm.uk_preprod
    }
    resource_group_name = "uksouth-preprod"
    location = "uksouth"
    tags = {
        "Environment" = "Pre-Production",
    }

    keyvault_users = {
        Backend = { object_id = "219194f6-b186-4146-9be7-34b731e19001" },
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-preprod-common",
        },
        hermes = {
            name = "bink-uksouth-preprod-hermes",
        },
        hades = {
            name = "bink-uksouth-preprod-hades",
        },
        harmonia = {
            name = "bink-uksouth-preprod-harmonia",
            sku_name = "GP_Gen5_4",
        },
    }
    redis_config = {
        common = {
            name = "bink-uksouth-preprod-common",
        },
    }
    storage_config = {
        common = {
            name = "binkuksouthpreprod",
            account_replication_type = "GZRS",
        },
    }
}

module "uksouth_preprod_cluster_1" {
    source = "./modules/cluster"
    providers = {
        azurerm = azurerm.uk_preprod
        azurerm.uk_core = azurerm
    }

    resource_group_name = "uksouth-preprod-k1"
    location = "uksouth"
    vnet_cidr = "10.69.0.0/16"

    # Gitops repo, Managed identity for syncing common secrets
    gitops_repo = "git@git.bink.com:DevOps/gitops/tools.k8s.uksouth.bink.sh.git"
    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity

    # DNS zones
    private_dns = module.uksouth-dns.private_dns

    # Peers    
    peers = {
        firewall = {
            vnet_id = module.uksouth-firewall.vnet_id
            vnet_name = module.uksouth-firewall.vnet_name
            resource_group_name = module.uksouth-firewall.resource_group_name
        }
    }










    tags = {
        "Environment" = "Pre-Production",
    }
}








output "uksouth_preprod_passwords" {
    value = module.uksouth_preprod_environment.passwords
    sensitive = false
}
output "uksouth_preprod_managedidentites" {
    value = module.uksouth_preprod_environment.managedidentites
    sensitive = false
}
