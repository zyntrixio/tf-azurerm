terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "common" {
  type = object({
    location = optional(string, "uksouth")
  })
}

variable "permissions" {
  type = object({
    admins        = list(string)
    editors       = optional(list(string), [])
    readers       = optional(list(string), [])
    subscriptions = optional(map(string), {})
  })
}

variable "workspace_integrations" {
  type    = list(string)
  default = []
}

resource "azurerm_resource_group" "i" {
  name     = "${var.common.location}-grafana"
  location = var.common.location
}

resource "azurerm_dashboard_grafana" "i" {
  name                              = "${var.common.location}-grafana"
  resource_group_name               = azurerm_resource_group.i.name
  location                          = var.common.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true
  grafana_major_version             = 10

  identity {
    type = "SystemAssigned"
  }

  dynamic "azure_monitor_workspace_integrations" {
    for_each = var.workspace_integrations
    content {
      resource_id = azure_monitor_workspace_integrations.value
    }
  }
}

resource "azurerm_role_assignment" "subscriptions" {
  for_each             = var.permissions.subscriptions
  scope                = "/subscriptions/${each.value}"
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.i.identity[0].principal_id
}

resource "azurerm_role_assignment" "admins" {
  for_each             = toset(var.permissions.admins)
  scope                = azurerm_dashboard_grafana.i.id
  role_definition_name = "Grafana Admin"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "editors" {
  for_each             = toset(var.permissions.editors)
  scope                = azurerm_dashboard_grafana.i.id
  role_definition_name = "Grafana Editor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "readers" {
  for_each             = toset(var.permissions.readers)
  scope                = azurerm_dashboard_grafana.i.id
  role_definition_name = "Grafana Viewer"
  principal_id         = each.value
}
