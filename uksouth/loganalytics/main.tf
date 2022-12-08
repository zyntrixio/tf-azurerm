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

output "id" {
    value = azurerm_log_analytics_workspace.i.id
}

resource "azurerm_log_analytics_workspace" "temp" {
    name = "${azurerm_resource_group.i.name}-temp"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    sku = "PerGB2018"
    retention_in_days = 365
}
