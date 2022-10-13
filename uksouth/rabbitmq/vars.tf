variable "resource_group_name" {}
variable "location" {}
variable "tags" {}
variable "vnet_cidr" {}
variable "base_name" {}
variable "rabbit_count" { default = 3 }
variable "peering_remote_id" {}
variable "peering_remote_rg" {}
variable "peering_remote_name" {}
variable "cluster_cidrs" { type = list }

variable "private_dns" {
    type = object({
        resource_group = string
        primary_zone = string
        secondary_zones = list(string)
    })
}
