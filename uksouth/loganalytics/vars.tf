variable "vnet_cidr" {}

variable "peers" { type = map(object({
    vnet_id = string
    vnet_name = string
    resource_group_name = string
})) }

variable "private_dns_link_bink_host" { type = list }
