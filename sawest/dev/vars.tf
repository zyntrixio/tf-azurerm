variable environment { default = "dev" }
variable location { default = "southafricanorth" }
variable resource_group_name { default = "sanorth-dev" }
variable address_space { default = "10.12.0.0/16" }

variable subnet_address_prefixes {
  default = [
    "10.12.0.0/18", # Kubernetes Workers
    "10.12.64.0/24", # Kubernetes Controllers/ectd
  ]
}
variable worker_vm_size { default = "Standard_D2s_v3" }
variable worker_count { default = 3 }
variable controller_vm_size { default = "Standard_D2s_v3" }
variable controller_count { default = 1 }
