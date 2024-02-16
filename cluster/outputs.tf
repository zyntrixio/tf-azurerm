output "aks" {
  value = azurerm_kubernetes_cluster.i
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

locals {
  nextdns_redis_optional = var.redis.enabled ? {
    (azurerm_redis_cache.i[0].hostname) : cidrhost(one(azurerm_subnet.redis.address_prefixes), 4),
  } : {}
}

output "nextdns" {
  value = merge(local.nextdns_redis_optional, {
    (azurerm_kubernetes_cluster.i.fqdn) : cidrhost(one(azurerm_subnet.kube_controller.address_prefixes), 4),
    (azurerm_postgresql_flexible_server.i.fqdn) : cidrhost(one(azurerm_subnet.postgres.address_prefixes), 4),
    "${var.common.name}.${azurerm_resource_group.i.location}.bink.sh" : cidrhost(cidrsubnet(var.common.cidr, 1, 0), 32766)
  })
}

output "prometheus" {
  value = azurerm_monitor_workspace.i.id
}
