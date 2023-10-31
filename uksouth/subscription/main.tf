variable "subscription_id" {
    type = map(string)
    default = {}
}

variable "users" {
    type = map(string)
    default = {}
}

locals {
    permissions = merge([
        for subscription_key, subscription_value in var.subscription_id : {
            for aad_key, aad_value in var.users :
                "${subscription_key}-${aad_key}" => {
                    "subscription_id" = subscription_value,
                    "aad_user" = aad_value,
                }
            }
    ]...)
}

resource "azurerm_role_assignment" "i" {
    for_each = local.permissions
    scope = each.value.subscription_id
    role_definition_name = "Owner"
    principal_id = each.value.aad_user
}
