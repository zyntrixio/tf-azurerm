output "aks" {
    value = var.kube.enabled ? azurerm_kubernetes_cluster.i[0] : null
}

output "managed_identities" {
    value = {
        for k, v in azurerm_user_assigned_identity.i : k => v.principal_id
    }
}

output "storage" {
    value = var.storage.enabled ? azurerm_storage_account.i[0] : null
}
