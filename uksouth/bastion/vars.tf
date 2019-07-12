variable environment { default = "bastion" }
variable location { default = "uksouth" }

variable subnet_address_prefixes {
  default = [
    "192.168.4.0/24", # Kubernetes Workers
  ]
}
variable bastion_vm_size { default = "Standard_B2s" }
variable bastion_count { default = 2 }
