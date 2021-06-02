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
