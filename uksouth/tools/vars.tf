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
variable controller_vm_size { default = "Standard_D2s_v3" }
variable controller_count { default = 1 }
