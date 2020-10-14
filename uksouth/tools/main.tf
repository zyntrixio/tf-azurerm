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
            "Microsoft.Network/networkInterfaces/read"
        ]
        not_actions = []
    }

    assignable_scopes = [
        data.azurerm_subscription.current.id,
    ]
}

resource "azurerm_role_assignment" "prometheus_azure_vm_read" {
    scope = data.azurerm_subscription.current.id
    role_definition_id = azurerm_role_definition.prometheus_azure_vm_read.role_definition_resource_id
    principal_id = azurerm_user_assigned_identity.prometheus.principal_id
}
