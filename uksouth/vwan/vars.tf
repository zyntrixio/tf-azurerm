# Module Variables
variable "firewall_vnet_id" {}

variable environment { default = "vwan" }
variable "uk_hub_ip_range" { default = "172.30.0.0/22" }
variable "uk_p2s_ip_range" { default = "172.30.4.0/22" }
variable "ascot_ip_range" { default = "172.30.8.0/22" }
variable "london_ip_range" { default = "172.30.12.0/22" }

variable "tags" {
    type = map
    default = {
        Environment = "Virtual WAN"
    }
}
