variable "private_dns_link_bink_host" {}

variable location { default = "uksouth" }
variable environment { default = "chef" }

variable "tags" {
    type = map
    default = {
        Environment = "Core"
    }
}

variable "loganalytics_id" {
    type = string
}
