variable resource_group_name { type = string }
variable location { type = string }
variable tags { type = map(string) }
variable vnet_cidr { type = string }

variable private_dns { type = map(object({
    resource_group_name = string
    private_dns_zone_name = string
    should_register = bool
})) }

variable peers { type = map(object({
    vnet_id = string
    vnet_name = string
    resource_group_name = string
})) }
# variable private_dns_link_bink_host { type = map(string) }
# variable "private_dns_link_bink_sh" {}

variable gitops_repo { type = string }
variable common_keyvault {}
variable common_keyvault_sync_identity {}
