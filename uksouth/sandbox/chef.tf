resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name
    cookbook_constraints = {
        bifrost = "= 2.6.1"
        fury = "= 1.5.0"
        jarvis = "= 2.0.0"
        romanoff = "= 2.1"
    }

    default_attributes_json = jsonencode({
        "common_secrets" : {
            "keyvault_url" : var.common_keyvault.url,
            "keyvault2kube_resourceid" : var.common_keyvault_sync_identity.resource_id,
            "keyvault2kube_clientid" : var.common_keyvault_sync_identity.client_id
        }
    })
}
