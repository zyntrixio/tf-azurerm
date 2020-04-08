variable environment { default = "dev" }
variable resource_group_name { default = "uksouth-dev" }
variable address_space { default = "10.2.0.0/16" }

variable subnet_address_prefixes {
  type = list
  default = [
    "10.2.0.0/18", # Kubernetes Workers
    "10.2.64.0/24", # Kubernetes Controllers/ectd
  ]
}

variable "tags" {
  type = map
  default = {
    Environment = "Dev"
  }
}

variable worker_vm_size { default = "Standard_D4s_v3" }
variable worker_count { default = 6 }
variable controller_vm_size { default = "Standard_D2s_v3" }
variable controller_count { default = 1 }
