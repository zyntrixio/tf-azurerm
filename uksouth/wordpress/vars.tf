variable environment { default = "wordpress" }

variable "tags" {
    type = map
    default = {
        Environment = "Core"
    }
}

variable "secure_origins" {
    type = list
    default = []
}

variable "dns_zone" { default = {} }
variable "frontdoor_id" { default = {} }
