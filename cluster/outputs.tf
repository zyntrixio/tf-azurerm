output "aks" {
    value = azurerm_kubernetes_cluster.i[0]
}

output "managed_identities" {
    value = {
        for k, v in azurerm_user_assigned_identity.i : k => v.principal_id
    }
}

output "storage" {
    value = azurerm_storage_account.i[0]
}
