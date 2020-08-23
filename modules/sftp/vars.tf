variable resource_group_name { type = string }
variable location { type = string }
variable tags { type = map }

variable resource_group_iam {
    type = map
    default = {}
}

variable vnet_cidr { type = string }

variable peers { type = map(object({
    vnet_id = string
    vnet_name = string
    resource_group_name = string
})) }

variable private_dns { type = map(object({
    resource_group_name = string
    private_dns_zone_name = string
    should_register = bool
})) }

variable public_dns { type = map(object({
    resource_group_name = string
    dns_zone_name = string
})) }

variable sftp_users { type = map }

variable firewall { type = object({
    firewall_name = string
    resource_group_name = string
    ingress_priority = number
    public_ip = string
    ingress_source = string
    ingress_sftp = number
}) }
