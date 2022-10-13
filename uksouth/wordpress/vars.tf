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

variable "frontdoor_id" { default = {} }

variable "loganalytics_id" {
    type = string
}

variable "dns" {
    type = object({
        zone = string
        resource_group = string
    })
}
