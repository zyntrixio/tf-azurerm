variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "ip_range" { type = string }

variable "production_cidrs" {
  type = list
  default = []
}

variable "secure_origins" {
    type = list
    default = []
}

variable "lloyds_origins" {
    type = list
    default = [] 
}

variable "loganalytics_id" {
    type = string
}

variable "aks_cidrs" {
    type = map
    default = {}
}
