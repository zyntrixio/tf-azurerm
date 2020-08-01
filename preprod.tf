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

output "uksouth_preprod_passwords" {
    value = module.uksouth_preprod_environment.passwords
    sensitive = false
}
output "uksouth_preprod_managedidentites" {
    value = module.uksouth_preprod_environment.managedidentites
    sensitive = false
}
