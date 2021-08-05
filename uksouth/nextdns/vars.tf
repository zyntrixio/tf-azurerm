variable environment { default = "nextdns" }

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
