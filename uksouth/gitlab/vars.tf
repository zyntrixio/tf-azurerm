# Module required vars:
variable "firewall_vnet_id" {}
variable "firewall_route_ip" {}

# Defaults:

variable environment { default = "gitlab" }

variable "ip_range" { default = "192.168.10.0/24" }

variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

