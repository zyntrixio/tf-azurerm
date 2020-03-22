variable environment { default = "bastion" }

variable subnet_address_prefixes {
  type = list
  default = ["192.168.4.0/24"]
}

variable "tags" {
  type = map
  default = {
    Environment = "Production"
  }
}

variable bastion_vm_size { default = "Standard_B2s" }
variable bastion_count { default = 2 }
