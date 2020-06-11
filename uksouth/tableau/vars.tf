# Module Variables
variable worker_subnet {}
variable "firewall_vnet_id" {}

variable environment { default = "tableau" }
variable "ip_range" { default = "192.168.7.0/24" }

variable "tags" {
    type = map
    default = {
        Environment = "Tableau"
    }
}

variable "vpn_subnet_id" {}
