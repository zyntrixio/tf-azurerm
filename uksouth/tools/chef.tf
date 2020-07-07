resource "chef_environment" "env" {
    name = var.resource_group_name
    cookbook_constraints = {
        bifrost = ">= 2.6.2"
        romanoff = ">= 2.0.2"
        fury = ">= 1.5.1"
    }

    default_attributes_json = jsonencode({
        "flux" : {
            "repo" : var.gitops_repo,
        },
        "common_secrets" : {
            "keyvault_url" : var.common_keyvault.url,
            "keyvault2kube_resourceid" : var.common_keyvault_sync_identity.resource_id,
            "keyvault2kube_clientid" : var.common_keyvault_sync_identity.client_id
        }
    })
}


resource "commandpersistence_cmd" "databag_secret" {
    program = ["python3", "${path.root}/scripts/generate-secret.py"]
}

resource "chef_data_bag" "databag" {
    name = var.resource_group_name
}

resource "commandpersistence_cmd" "certs" {
    program = ["python3", "${path.root}/scripts/generate-certificates.py"]

    query = {
        key = commandpersistence_cmd.databag_secret.result.secret
        data_bag_name = chef_data_bag.databag.id
    }
}

# To reference within the same module: commandpersistence_cmd.databag_secret.result.secret
output "databag_secret" {
    value = commandpersistence_cmd.databag_secret.result.secret
    sensitive = true
}
