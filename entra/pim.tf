
data "azurerm_subscription" "i" {}

data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "reader" {
  name = "Azure Kubernetes Service Cluster User Role"

}

data "azurerm_role_definition" "writer" {
  name = "Azure Kubernetes Service RBAC Writer"

}

resource "time_static" "now" {}

resource "azurerm_pim_eligible_role_assignment" "reader" {
  scope              = data.azurerm_subscription.i.id
  role_definition_id = "${data.azurerm_subscription.i.id}${data.azurerm_role_definition.reader.id}"
  principal_id       = data.azurerm_client_config.current.object_id

  schedule {
    start_date_time = time_static.now.rfc3339
    expiration {
      duration_hours = 8
    }
  }

  justification = ""

}

resource "azurerm_pim_eligible_role_assignment" "writer" {
  scope              = data.azurerm_subscription.i.id
  role_definition_id = "${data.azurerm_subscription.i.id}${data.azurerm_role_definition.writer.id}"
  principal_id       = data.azurerm_client_config.current.object_id

  schedule {
    start_date_time = time_static.now.rfc3339
    expiration {
      duration_hours = 8
    }
  }

  justification = ""

}