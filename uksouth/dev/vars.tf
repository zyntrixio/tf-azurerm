variable subnet_address_prefixes {
  default = [
    "10.2.0.0/18", # Kubernetes Workers
    "10.2.64.0/24", # Kubernetes Controllers/ectd
  ]
}
variable worker_vm_size { default = "Standard_B2s" }
variable controller_etcd_vm_size { default = "Standard_B2s" }
