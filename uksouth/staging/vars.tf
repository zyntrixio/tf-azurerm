variable "private_dns_link_bink_host" {}
variable "private_dns_link_bink_sh" {}

variable common_keyvault {}
variable common_keyvault_sync_identity {}

variable environment { default = "staging" }
variable resource_group_name { default = "uksouth-staging" }
variable address_space { default = "10.1.0.0/16" }

variable subnet_address_prefixes {
    default = [
        "10.1.0.0/18", # Kubernetes Workers
        "10.1.64.0/24", # Kubernetes Controllers/etcd
    ]
}

variable "tags" {
    type = map
    default = {
        Environment = "Staging"
    }
}

variable worker_vm_size { default = "Standard_D4s_v3" }
variable worker_count { default = 8 }
variable controller_vm_size { default = "Standard_D2s_v3" }
variable controller_count { default = 1 }
