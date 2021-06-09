module "uksouth_oat_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=1.7.7"
    providers = {
        azurerm = azurerm.uk_sandbox
    }
    resource_group_name = "uksouth-oat"
    location = "uksouth"
    tags = {
        "Environment" = "Barclays OAT",
    }

    resource_group_iam = {
        # Backend = {
        #     object_id = "219194f6-b186-4146-9be7-34b731e19001",
        #     role = "Reader",
        # },
        # QA = {
        #     object_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d",
        #     role = "Reader",
        # },
    }

    keyvault_users = {
        ChristianPrior = { object_id = "ae282437-d730-4342-8914-c936e8289cdc" },
        KashimAziz = { object_id = "b004c980-3e08-4237-b8e2-d6e65d2bef3f" },
    }
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    storage_config = {
        common = {
            name = "binkuksouthoat",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
    cert_manager_zone_id = module.uksouth-dns.bink-sh[2]
}
