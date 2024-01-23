resource "azurerm_monitor_workspace" "i" {
  name                = "${var.common.location}-${var.common.name}"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
}

resource "azurerm_monitor_data_collection_endpoint" "i" {
  name                = "MSProm-${azurerm_resource_group.i.name}"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  kind                = "Linux"
}

resource "azurerm_monitor_data_collection_rule" "i" {
  name                        = "MSProm-${azurerm_resource_group.i.name}"
  resource_group_name         = azurerm_resource_group.i.name
  location                    = azurerm_resource_group.i.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.i.id
  kind                        = "Linux"

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.i.id
      name               = "MonitoringAccount1"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount1"]
  }


  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"
  depends_on = [
    azurerm_monitor_data_collection_endpoint.i
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "i" {
  count                   = var.kube.enabled ? 1 : 0
  name                    = "MSProm-${azurerm_resource_group.i.name}"
  target_resource_id      = azurerm_kubernetes_cluster.i[0].id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.i.id
  description             = "Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster."
  depends_on = [
    azurerm_monitor_data_collection_rule.i
  ]
}
