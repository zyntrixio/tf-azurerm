resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = "uksouth"

    tags = var.tags
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azurerm_user_assigned_identity" "prometheus" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    name = "prometheus"
}

resource "azurerm_role_definition" "prometheus_azure_vm_read" {
    name = "prometheus_vm_read"
    scope = data.azurerm_subscription.current.id

    permissions {
        actions = [
            "Microsoft.Compute/virtualMachines/read",
            "Microsoft.Compute/virtualMachineScaleSets/read",
            "Microsoft.Network/networkInterfaces/read"
        ]
        not_actions = []
    }

    assignable_scopes = [
        data.azurerm_subscription.current.id,
        "/subscriptions/79560fde-5831-481d-8c3c-e812ef5046e5",
        "/subscriptions/6e685cd8-73f6-4aa6-857c-04ed9b21d17d",
        "/subscriptions/457b0db5-6680-480f-9e77-2dafb06bd9dc",
        "/subscriptions/794aa787-ec6a-40dd-ba82-0ad64ed51639",
        "/subscriptions/957523d8-bbe2-4f68-8fae-95975157e91c"
    ]
}

resource "azurerm_role_assignment" "prometheus_azure_vm_read" {
    scope = data.azurerm_subscription.current.id
    role_definition_id = azurerm_role_definition.prometheus_azure_vm_read.role_definition_resource_id
    principal_id = azurerm_user_assigned_identity.prometheus.principal_id
}

locals {
    subs = toset([
        "/subscriptions/79560fde-5831-481d-8c3c-e812ef5046e5",
        "/subscriptions/6e685cd8-73f6-4aa6-857c-04ed9b21d17d",
        "/subscriptions/457b0db5-6680-480f-9e77-2dafb06bd9dc",
        "/subscriptions/794aa787-ec6a-40dd-ba82-0ad64ed51639",
        "/subscriptions/957523d8-bbe2-4f68-8fae-95975157e91c"
    ])
}

resource "azurerm_role_assignment" "prometheus_azure_vm_read_subs" {
    for_each = local.subs

    scope = each.value
    role_definition_id = azurerm_role_definition.prometheus_azure_vm_read.role_definition_resource_id
    principal_id = azurerm_user_assigned_identity.prometheus.principal_id
}
