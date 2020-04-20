variable environment { default = "vault" }

variable subnet_address_prefixes {
    default = [
        "192.168.1.0/25", # Vault
        "192.168.1.128/25", # etcd
    ]
}

variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable vault_vm_size { default = "Standard_D2s_v3" }
variable vault_count { default = 3 }
variable etcd_vm_size { default = "Standard_D2s_v3" }
variable etcd_count { default = 3 }
