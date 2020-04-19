variable environment { default = "sentry" }

variable "tags" {
  type = map
  default = {
    Environment = "Production"
  }
}

variable "ip_range" { default = "192.168.2.0/24" }

variable "firewall_vnet_id" {}
