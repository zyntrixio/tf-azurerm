resource "chef_environment" "env" {
    name = var.resource_group_name
    cookbook_constraints = {
        bifrost = "= ${var.bifrost_version}"
        romanoff = ">= 2.0.2"
        fury = ">= 1.6.1"
        nebula = "= 2.1.0"
    }

    default_attributes_json = jsonencode({
        "kubernetes" : {
            "api" : {
                "host" : "${var.cluster_name}.uksouth.bink.sh",
                "ipaddress" : cidrhost(cidrsubnet(var.vnet_cidr, 8, 64), 4)  # Removes depenency on subnet
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
                "subnet_name" : azurerm_subnet.worker.name,
                "security_group_name" : azurerm_network_security_group.worker_nsg.name,
                "primary_availability_set_name" : azurerm_availability_set.worker.name,
                "worker_cidr" : cidrsubnet(var.vnet_cidr, 2, 0)
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
# output "databag_secret" {
#     value = commandpersistence_cmd.databag_secret.result.secret
#     sensitive = true
# }
