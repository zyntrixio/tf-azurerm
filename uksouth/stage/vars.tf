variable subnet_address_prefixes {
  default = [
    "10.1.0.0/18", # Kubernetes Workers
    "10.1.64.0/24", # Kubernetes Controllers/etcd
  ]
}
variable worker_vm_size { default = "Standard_D8s_v3" }
variable controller_etcd_vm_size { default = "Standard_D4s_v3" }
