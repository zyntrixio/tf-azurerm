variable environment { default = "prod" }
variable location { default = "uksouth" }
variable resource_group_name { default = "uksouth-prod" }
variable address_space { default = "10.0.0.0/16" }

variable subnet_address_prefixes {
  default = [
    "10.0.0.0/18", # Kubernetes Workers
    "10.0.64.0/24", # Kubernetes Controllers
    "10.0.65.0/24", # etcd Hosts
  ]
}
variable worker_vm_size { default = "Standard_D8s_v3" }
variable worker_count { default = 5 }
variable controller_vm_size { default = "Standard_D4s_v3" }
variable controller_count { default = 3 }
variable etcd_vm_size { default = "Standard_D2s_v3" }
variable etcd_count { default = 5 }
