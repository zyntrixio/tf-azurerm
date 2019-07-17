variable location { default = "uksouth" }
variable environment { default = "chef" }

variable subnet_address_prefixes {
  default = [
    "192.168.5.0/24", # Kubernetes Workers
  ]
}
