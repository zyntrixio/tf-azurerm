locals {
    subscription_id = {
        "uksouth_tools" = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009"
        "uksouth_dev" = "/subscriptions/6a36a6fd-e97c-42f2-88ff-2484d8165f53"
        "uksouth_staging" = "/subscriptions/e28b2912-1f6d-4ac7-9cd7-443d73876e10"
        "uksouth_sandbox" = "/subscriptions/64678f82-1a1b-4096-b7e9-41b1bdcdc024"
        "uksouth_perf" = "/subscriptions/c49c2fde-9e7d-41c6-ac61-f85f9fa51416"
        "uksouth_prod" = "/subscriptions/42706d13-8023-4b0c-b98a-1a562cb9ac40"
    }
    aad_user = {
        chris_pressland = "48aca6b1-4d56-4a15-bc92-8aa9d97300df"
        nathan_read = "bba71e03-172e-4d07-8ee4-aad029d9031d"
        thenuja_viknarajah = "e69fd5a7-8b6c-4ac5-8df0-c88c77df0a12"
    }
    permissions = [
        for subscription_key, subscription_value in local.subscription_id : {
            for aad_key, aad_value in local.aad_user :
                "${subscription_key}-${aad_key}" => {
                    "subscription_id" = subscription_value,
                    "aad_user" = aad_value,
                }
        }
    ]
}

resource "azurerm_role_assignment" "sub_owner" {
    for_each = local.permissions
    scope = each.value.subscription_id
    role_definition_name = "Owner"
    principal_id = each.value.aad_user
}
