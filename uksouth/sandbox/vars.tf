variable environment { default = "sandbox" }
variable address_space { default = "10.3.0.0/16" }

variable subnet_address_prefixes {
  default = [
    "10.3.0.0/18", # Kubernetes Workers
    "10.3.64.0/24", # Kubernetes Controllers/ectd
  ]
}

variable "tags" {
  type = map
  default = {
    Environment = "Sandbox"
  }
}

variable worker_vm_size { default = "Standard_D4s_v3" }
variable worker_count { default = 4 }
variable controller_vm_size { default = "Standard_D2s_v3" }
variable controller_count { default = 1 }
