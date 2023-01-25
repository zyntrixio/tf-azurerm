terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
    }
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

resource "azurerm_role_assignment" "secops" {
    scope = azurerm_log_analytics_workspace.i.id
    role_definition_name = "Contributor"
    principal_id = "b56bc76d-1af5-4e44-8784-7ee7a44cc0c1"
}

resource "azurerm_role_assignment" "backend" {
    scope = azurerm_log_analytics_workspace.i.id
    role_definition_name = "Contributor"
    principal_id = "219194f6-b186-4146-9be7-34b731e19001"
}

resource "azurerm_role_assignment" "qa" {
    scope = azurerm_log_analytics_workspace.i.id
    role_definition_name = "Contributor"
    principal_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d"
}

resource "azurerm_role_assignment" "datamanagement" {
    scope = azurerm_log_analytics_workspace.i.id
    role_definition_name = "Contributor"
    principal_id = "13876e0a-d625-42ff-89aa-3f6904b2f073"
}

resource "azurerm_role_assignment" "architecture" {
    scope = azurerm_log_analytics_workspace.i.id
    role_definition_name = "Contributor"
    principal_id = "fb26c586-72a5-4fbc-b2b0-e1c28ef4fce1"
}

locals {
    snowstorm_principle_ids = [
        "67d0e3c4-1e19-4392-87bd-f02c5984f413", 
        "a520804c-c43f-4002-b048-6c4369b503a5", 
        "73fd3c41-56d8-48de-ad15-4ad622f56017", 
        "ad8d9dba-4ffc-44de-ae61-04e119bbffb4", 
        "a3dd0160-9f25-48a5-b7e6-dc288af62b8e",
    ]
}

resource "azurerm_role_assignment" "snowstorm" {
    for_each = toset(local.snowstorm_principle_ids)
    scope = azurerm_log_analytics_workspace.i.id
    role_definition_name = "Reader"
    principal_id = each.key
}
output "id" {
    value = azurerm_log_analytics_workspace.i.id
}
