variable location { default = "uksouth" }
variable environment { default = "chef" }

variable subnet_address_prefixes {
  type = list
  default = ["192.168.5.0/24"]
}

variable "tags" {
  type = map
  default = {
    Environment = "Production"
  }
}
