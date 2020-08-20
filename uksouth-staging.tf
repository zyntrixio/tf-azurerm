module "uksouth_staging_environment" {
    source = "./modules/environment"
    providers = {
        azurerm = azurerm.uk_staging
    }
    resource_group_name = "uksouth-staging"
    location = "uksouth"
    tags = {
        "Environment" = "Staging",
    }

    resource_group_iam = {
        Backend = {
            object_id = "219194f6-b186-4146-9be7-34b731e19001",
            role = "Reader",
        },
        QA = {
            object_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d",
            role = "Reader",
        },
    }

    keyvault_users = {
        Backend = { object_id = "219194f6-b186-4146-9be7-34b731e19001" },
        QA = { object_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d" },
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-staging-common",
            sku_name = "GP_Gen5_4",
            storage_gb = 100,
            databases = ["*"]
        },
    }
    redis_config = {
        common = {
            name = "bink-uksouth-staging-common",
        },
    }
    storage_config = {
        common = {
            name = "binkuksouthstaging",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
}
