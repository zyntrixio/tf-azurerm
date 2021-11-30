variable "common_name" { default = "sftp" }

variable "tags" {
    type = map
    default = {
        Environment = "Core"
    }
}

variable "ip_range" { default = "192.168.20.0/24" }

variable "private_dns_link_bink_host" {}

variable "peers" { type = map(object({
    vnet_id = string
    vnet_name = string
    resource_group_name = string
})) }

variable "config" {
    default = {}
}

variable "loganalytics_id" {
    type = string
}
