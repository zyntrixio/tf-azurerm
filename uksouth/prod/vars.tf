variable subnet_address_prefixes {
    default = [
        "10.0.0.0/18", # Kubernetes Workers
        "10.0.64.0/24", # Kubernetes Controllers
        "10.0.65.0/24", # etcd Hosts
        "10.0.66.0/24", # Bastion Hosts
    ]
}
