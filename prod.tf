module "uksouth_prod_environment" {
    source = "./modules/environment"
    providers = {
        azurerm = azurerm.uk_production
    }
    resource_group_name = "uksouth-prod"
    location = "uksouth"
    tags = {
        "Environment" = "Production",
    }

    resource_group_iam = {
        Backend = {
            object_id = "219194f6-b186-4146-9be7-34b731e19001",
            role = "Reader",
        },
        MickLatham = {
            object_id = "343299d4-0a39-4109-adce-973ad29d0183",
            role = "Contributor",
        },
        ChrisLatham = {
            object_id = "607482a3-07fa-4b24-8af0-5b84df6ca7c6",
            role = "Contributor",
        },
        ChristianPrior = {
            object_id = "ae282437-d730-4342-8914-c936e8289cdc",
            role = "Contributor",
        },
    }

    keyvault_users = {
        MickLatham = { object_id = "343299d4-0a39-4109-adce-973ad29d0183" },
        ChrisLatham = { object_id = "607482a3-07fa-4b24-8af0-5b84df6ca7c6" },
        ChristianPrior = { object_id = "ae282437-d730-4342-8914-c936e8289cdc" },
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-prod-common",
        },
        hermes = {
            name = "bink-uksouth-prod-hermes",
            sku_name = "GP_Gen5_4",
        },
        hades = {
            name = "bink-uksouth-prod-hades",
            sku_name = "GP_Gen5_4",
        },
        harmonia = {
            name = "bink-uksouth-prod-harmonia",
            sku_name = "GP_Gen5_4",
        },
    }
    redis_config = {
        common = {
            name = "bink-uksouth-prod-common",
        },
        harmonia = {
            name = "bink-uksouth-prod-harmonia",
            family = "P",
            sku_name = "Premium",
        },
    }
    storage_config = {
        common = {
            name = "binkuksouthprod",
            account_replication_type = "GZRS",
        },
    }
}

output "uksouth_prod_passwords" {
    value = module.uksouth_prod_environment.passwords
    sensitive = false
}
output "uksouth_prod_managedidentites" {
    value = module.uksouth_prod_environment.managedidentites
    sensitive = false
}
