variable subnet_address_prefixes {
  default = [
    "10.0.0.0/18", # Kubernetes Workers
    "10.0.64.0/24", # Kubernetes Controllers
    "10.0.65.0/24", # etcd Hosts
    "10.0.66.0/24", # Bastion Hosts
  ]
}
variable worker_vm_size { default = "Standard_D8s_v3" }
variable controller_vm_size { default = "Standard_D4s_v3" }
variable etcd_vm_size { default = "Standard_D2s_v3" }
variable bastion_vm_size { default = "Standard_B2s" }
