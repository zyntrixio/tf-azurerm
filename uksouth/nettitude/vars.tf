variable environment { default = "nettitude" }
variable location { default = "uksouth" }
variable resource_group_name { default = "uksouth-nettitude" }

variable subnet_address_prefixes {
  default = [
    "192.168.250.0/24",
  ]
}
