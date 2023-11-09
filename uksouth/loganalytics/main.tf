terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
    }
}

variable "managed_identities" {
    type = list
    default = []
}

variable "iam" {
    type = list
    default = []
}

resource "azurerm_resource_group" "i" {
    name = "uksouth-loganalytics"
    location = "uksouth"
}

resource "azurerm_log_analytics_workspace" "i" {
    name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    sku = "PerGB2018"
    retention_in_days = 365
}

resource "azurerm_role_assignment" "iam" {
    for_each = toset(var.iam)
    scope = azurerm_log_analytics_workspace.i.id
    role_definition_name = "Log Analytics Reader"
    principal_id = each.key
}

resource "azurerm_role_assignment" "cluster_ids" {
    for_each = toset(var.managed_identities)
    scope = azurerm_log_analytics_workspace.i.id
    role_definition_name = "Log Analytics Reader"
    principal_id = each.key
}

output "id" {
    value = azurerm_log_analytics_workspace.i.id
}
