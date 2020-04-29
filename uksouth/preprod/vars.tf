variable worker_subnet {}

variable environment { default = "preprod" }
variable resource_group_name { default = "uksouth-preprod" }

variable "tags" {
    type = map
    default = {
        Environment = "Pre Production"
    }
}
