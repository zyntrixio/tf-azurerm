locals {
  nfs_ips = [for ip in var.allowed_hosts.ipv4 : replace(ip, "/32", "")]
}

resource "random_string" "nfs" {
  length      = 4
  upper       = false
  special     = false
  min_numeric = 2
}

resource "azurerm_storage_account" "nfs" {
  count = var.storage.nfs_enabled ? 1 : 0

  name                = "${replace(azurerm_resource_group.i.name, "-", "")}nfs${random_string.nfs.result}"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name

  account_tier                     = "Standard"
  min_tls_version                  = "TLS1_2"
  account_replication_type         = "ZRS"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  is_hns_enabled                   = true
  nfsv3_enabled                    = true

  network_rules {
    default_action = "Deny"
    ip_rules       = local.nfs_ips
    virtual_network_subnet_ids = [
      azurerm_subnet.kube_nodes.id,
      "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-tailscale/providers/Microsoft.Network/virtualNetworks/uksouth-tailscale/subnets/subnet"
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "nfs" {
  count = var.storage.nfs_enabled && var.loganalytics.enabled ? 1 : 0

  name                       = "loganalytics"
  target_resource_id         = "${azurerm_storage_account.nfs[0].id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

  enabled_log { category = "StorageRead" }
  enabled_log { category = "StorageWrite" }
  enabled_log { category = "StorageDelete" }
  metric {
    category = "Capacity"
    enabled  = false
  }
  metric {
    category = "Transaction"
    enabled  = false
  }
}

resource "azurerm_role_assignment" "nfs_iam_ro" {
  for_each = {
    for k, v in var.iam : k => v
    if var.storage.sftp_enabled &&
    contains(v["assigned_to"], "nfs_ro") ||
    contains(v["assigned_to"], "st_ro")
  }

  scope                = azurerm_storage_account.nfs[0].id
  role_definition_name = "Reader"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "nfs_iam_rw" {
  for_each = {
    for k, v in var.iam : k => v
    if var.storage.sftp_enabled &&
    contains(v["assigned_to"], "nfs_rw") ||
    contains(v["assigned_to"], "st_rw")
  }

  scope                = azurerm_storage_account.nfs[0].id
  role_definition_name = "Contributor"
  principal_id         = each.key
}
