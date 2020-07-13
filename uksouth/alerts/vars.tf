variable location { default = "uksouth" }

variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}
