variable subnet_address_prefixes {
    default = [
        "192.168.1.0/25", # Vault
        "192.168.1.128/25", # etcd
    ]
}
variable vault_vm_size { default = "Standard_D2s_v3" }
variable etcd_vm_size { default = "Standard_D2s_v3" }
