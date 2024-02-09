output "aks" {
  value = var.kube.enabled ? azurerm_kubernetes_cluster.i[0] : null
}

output "managed_identities" {
  value = {
    for k, v in azurerm_user_assigned_identity.i : k => v.principal_id
  }
}

output "storage" {
  value = azurerm_storage_account.i
}

output "subnets" {
  value = {
    kube_nodes      = azurerm_subnet.kube_nodes.address_prefixes,
    kube_controller = azurerm_subnet.kube_controller.address_prefixes,
    postgres        = azurerm_subnet.postgres.address_prefixes,
    redis           = azurerm_subnet.redis.address_prefixes,
    tableau         = azurerm_subnet.tableau.address_prefixes,
    cloudamqp       = azurerm_subnet.cloudamqp.address_prefixes,
  }
}

output "prometheus" {
  value = azurerm_monitor_workspace.i.id
}
