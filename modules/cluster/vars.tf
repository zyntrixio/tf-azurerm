variable resource_group_name { type = string }
variable cluster_name { type = string }
variable location { type = string }
variable tags { type = map(string) }
variable vnet_cidr { type = string }
variable eventhub_authid { type = string }

variable firewall { type = object({
    firewall_name = string
    resource_group_name = string
    ingress_priority = number
    rule_priority = number
    public_ip = string
    secure_origins = list(string)
    developer_ips = list(string)
    ingress_source = string
    ingress_http = number
    ingress_https = number
    ingress_controller = number
}) }

variable tcp_endpoint {
    type = bool
    default = false
}
variable additional_firewall_rules {
    type = list(object({
        name = string
        source_addresses = list(string)
        destination_ports = list(string)
        destination_addresses = list(string)
        protocols = list(string)
    }))
    default = []
}


variable bifrost_version {
    type = string
    default = "4.0.0"
}

variable ubuntu_version {
    type = string
    default = "16.04"
}

variable postgres_servers {
    type = map(string)
}

variable private_dns { type = map(object({
    resource_group_name = string
    private_dns_zone_name = string
    should_register = bool
})) }

variable public_dns { type = map(object({
    resource_group_name = string
    dns_zone_name = string
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

variable controller_vm_size { default = "Standard_D2s_v3" }
variable worker_vm_size { default = "Standard_D4s_v3" }
variable worker_count { default = 3 }
