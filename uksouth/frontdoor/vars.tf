variable environment { default = "prod" }
variable resource_group_name { default = "frontdoor" }

variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable backends {
    type = map(list(object({
        host_header = string
        address = string
        http_port = number
        https_port = number
    })))
}
