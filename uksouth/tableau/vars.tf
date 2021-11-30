# Module Variables
variable worker_subnet {}
variable "firewall_vnet_id" {}
variable "private_dns_link_bink_host" {}
variable "wireguard_ip" {}

variable environment { default = "tableau" }
variable "ip_range" { default = "192.168.7.0/24" }

variable "tags" {
    type = map
    default = {
        Environment = "Tableau"
    }
}

variable "loganalytics_id" {
    type = string
}
