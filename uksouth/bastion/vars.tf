# Module required vars:
variable "firewall_vnet_id" {}
variable "firewall_route_ip" {}

# Defaults:

variable environment { default = "bastion" }

variable "ip_range" { default = "192.168.4.0/24" }

variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable bastion_vm_size { default = "Standard_B2s" }
variable flow_logs_enabled { default = false }
