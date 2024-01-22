terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.core]
    }
    cloudamqp = {
      source = "cloudamqp/cloudamqp"
    }
  }
}

data "azurerm_client_config" "i" {}
data "azurerm_subscription" "i" {}

resource "azurerm_resource_group" "i" {
  name     = "${var.common.location}-${var.common.name}"
  location = var.common.location
}

resource "azurerm_role_assignment" "rg_mi" {
  for_each = {
    for k, v in local.identities : k => v
    if contains(v["assigned_to"], "rg")
  }

  scope                = azurerm_resource_group.i.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "rg_iam" {
  for_each = {
    for k, v in var.iam : k => v
    if contains(v["assigned_to"], "rg")
  }

  scope                = azurerm_resource_group.i.id
  role_definition_name = "Reader"
  principal_id         = each.key
}
