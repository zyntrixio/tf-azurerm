variable environment { default = "prod" }
variable resource_group_name { default = "frontdoor" }

variable "tags" {
  type = map
  default = {
    Environment = "Production"
  }
}
