variable "resource_group_name" {}
variable "location" {}
variable "tags" {}
variable "vnet_cidr" {}
variable "cluster_cidrs" { type = list }
variable "peering_remote_id" {}
variable "peering_remote_rg" {}
variable "peering_remote_name" {}
variable "dns" {}
