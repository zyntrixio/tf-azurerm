locals {
    subscription_id = {
        "uksouth_tools" = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-tools-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-tools"
        "uksouth_dev" = "/subscriptions/6a36a6fd-e97c-42f2-88ff-2484d8165f53/resourceGroups/uksouth-dev-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-dev"
        "uksouth_staging" = "/subscriptions/e28b2912-1f6d-4ac7-9cd7-443d73876e10/resourceGroups/uksouth-staging-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-staging"
        "uksouth_sandbox" = "/subscriptions/64678f82-1a1b-4096-b7e9-41b1bdcdc024/resourceGroups/uksouth-barclays-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-barclays"
        "uksouth_perf" = "/subscriptions/c49c2fde-9e7d-41c6-ac61-f85f9fa51416/resourceGroups/uksouth-perf-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-perf"
        "uksouth_prod" = "/subscriptions/42706d13-8023-4b0c-b98a-1a562cb9ac40/resourceGroups/uksouth-prod-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-prod"
    }

    aad_user = {
        chris_pressland = "48aca6b1-4d56-4a15-bc92-8aa9d97300df"
        nathan_read = "bba71e03-172e-4d07-8ee4-aad029d9031d"
        thenuja_viknarajah = "e69fd5a7-8b6c-4ac5-8df0-c88c77df0a12"
    }
}


resource "azurerm_role_assignment" "sub_owner" {
    for_each = {
        for k in local.aad_user : k => v
    }
    scope = flatten([for id in local.subscription_id : id.value])
    role_definition_name = "Owner"
    principal_id = each.value
}
