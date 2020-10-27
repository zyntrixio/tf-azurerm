resource "chef_environment" "env" {
    name = var.resource_group_name
    cookbook_constraints = {
        bifrost = "= 4.3.1"
        romanoff = ">= 2.0.2"
        fury = ">= 1.6.1"
        nebula = "= 2.1.0"
    }

    default_attributes_json = jsonencode({
        "common_secrets" : {
            "keyvault_url" : var.common_keyvault.url,
            "keyvault2kube_resourceid" : var.common_keyvault_sync_identity.resource_id,
            "keyvault2kube_clientid" : var.common_keyvault_sync_identity.client_id
        },

        # New stuff
        "kubernetes" : {
            "api" : {
                "host" : "tools.k8s.uksouth.bink.sh",
                "ipaddress" : cidrhost(cidrsubnet(var.address_space, 8, 64), 4)  # Removes depenency on subnet
            }
        },
        "flux" : {
            "repo" : var.gitops_repo,
        },
        "azure" : {
            "keyvault" : {
                "url" : var.common_keyvault.url,
                "resource_id" : var.common_keyvault_sync_identity.resource_id,
                "client_id" : var.common_keyvault_sync_identity.client_id
            },
            "config" : {
                "subscription_id" : data.azurerm_subscription.current.subscription_id,
                "resource_group" : azurerm_resource_group.rg.name,
                "route_table_name" : azurerm_route_table.rt.name,
                "vnet_name" : azurerm_virtual_network.vnet.name,
                "vnet_resource_group" : azurerm_resource_group.rg.name,
                "subnet_name" : azurerm_subnet.subnet[0].name,
                "security_group_name" : azurerm_network_security_group.nsg[0].name,
                "primary_availability_set_name" : azurerm_availability_set.worker.name,
                "worker_cidr" : cidrsubnet(var.address_space, 2, 0)
            }
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
