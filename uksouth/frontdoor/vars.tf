variable environment { default = "prod" }
variable resource_group_name { default = "frontdoor" }

variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "secure_origins" {
    type = list
    default = []
}

variable "secure_origins_v6" {
    type = list
    default = []
}

variable "checkly_ips" {
    type = list
    default = [ "167.172.61.234/32", "167.172.53.20/32" ] # Lazy implementation, will make better in Front Door Premium
}

variable "loganalytics_id" {
    type = string
}
