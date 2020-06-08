variable environment { default = "wireguard" }

variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "ip_range" { default = "192.168.1.0/24" }

variable "firewall_vnet_id" {}
