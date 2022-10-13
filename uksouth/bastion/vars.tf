variable "firewall_vnet_id" {}
variable "firewall_route_ip" {}

variable "private_dns" {
    type = object({
        resource_group = string
        primary_zone = string
        secondary_zones = list(string)
    })
}

variable environment { default = "bastion" }

variable "ip_range" {}

variable "tags" {
    type = map
    default = {
        Environment = "Core"
    }
}

variable bastion_vm_size { default = "Standard_B2s" }

variable "loganalytics_id" {
    type = string
}
