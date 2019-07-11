variable subnet_address_prefixes {
  default = [
    "10.2.0.0/18", # Kubernetes Workers
    "10.2.64.0/24", # Kubernetes Controllers/ectd
  ]
}
variable worker_vm_size { default = "Standard_D4s_v3" }
variable worker_count { default = 2 }
variable controller_vm_size { default = "Standard_D2s_v3" }
variable controller_count { default = 1 }
