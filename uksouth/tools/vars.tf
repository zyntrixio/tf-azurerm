variable "private_dns_link_bink_host" {}
variable "private_dns_link_bink_sh" {}
variable gitops_repo {}
variable common_keyvault {}
variable common_keyvault_sync_identity {}

variable environment { default = "tools" }
variable resource_group_name { default = "uksouth-tools" }
variable address_space { default = "10.4.0.0/16" }

variable subnet_address_prefixes {
    type = list
    default = [
        "10.4.0.0/18", # Kubernetes Workers
        "10.4.64.0/24", # Kubernetes Controllers/ectd
    ]
}

variable "tags" {
    type = map
    default = {
        Environment = "Tools"
    }
}

variable worker_vm_size { default = "Standard_D4s_v3" }
variable worker_count { default = 3 }
variable test_worker_vm_size { default = "Standard_D4s_v3" }
variable test_worker_count { default = 0 }
variable controller_vm_size { default = "Standard_D2s_v3" }
variable controller_count { default = 1 }

# TODO move out
variable "devops_objectids" {
    type = map(object({
        object_id = string
    }))

    default = {
        TerryCain = { object_id = "f7c46488-2054-46de-9673-e0c6e94b232c" },
        ChrisPressland = { object_id = "48aca6b1-4d56-4a15-bc92-8aa9d97300df" },
        TomWinchester = { object_id = "de80162c-8e52-466b-affd-f3ccc0a66d5d" },
    }
}

variable "devops_keyvault_secretperms" {
    type = list(string)
    default = [
        "backup",
        "delete",
        "get",
        "list",
        "purge",
        "recover",
        "restore",
        "set",
    ]
}
