variable "common_name" { default = "sftp" }

variable "tags" {
    type = map
    default = {
        Environment = "Core"
    }
}

variable "ip_range" { type = string }

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

variable "private_dns" {
    type = object({
        resource_group = string
        primary_zone = string
        secondary_zones = list(string)
    })
}
