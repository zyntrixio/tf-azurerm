variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "sentry_vnet_id" {}
variable "sentry_ip_address" {}
