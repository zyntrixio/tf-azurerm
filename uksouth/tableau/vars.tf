# variable "firewall_id" {}
variable "firewall" { type = map }
variable "environment" { type = map }
variable "ip_range" { type = string }

variable postgres_flexible_server_dns_link { type = map }

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
