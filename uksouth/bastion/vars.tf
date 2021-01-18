# Module required vars:
variable "firewall_vnet_id" {}
variable "firewall_route_ip" {}
variable "private_dns_link_bink_host" {}
variable "private_dns_link_bink_sh" {}

# Defaults:

variable environment { default = "bastion" }

variable "ip_range" { default = "192.168.4.0/24" }

variable "tags" {
    type = map
    default = {
        Environment = "Core"
    }
}

variable bastion_vm_size { default = "Standard_B2s" }
