variable "private_dns_link_bink_host" {}
variable "private_dns_link_bink_sh" {}

variable environment { default = "sentry" }

variable "tags" {
    type = map
    default = {
        Environment = "Core"
    }
}

variable "ip_range" { default = "192.168.2.0/24" }

variable "firewall_vnet_id" {}
