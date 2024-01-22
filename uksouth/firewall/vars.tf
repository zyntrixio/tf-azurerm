variable "tags" {
  type = map(any)
  default = {
    Environment = "Production"
  }
}

variable "ip_range" { type = string }

variable "production_cidrs" {
  type    = list(any)
  default = []
}

variable "secure_origins" {
  type    = list(any)
  default = []
}

variable "lloyds_origins" {
  type    = list(any)
  default = []
}

variable "loganalytics_id" {
  type = string
}

variable "aks_cidrs" {
  type    = map(any)
  default = {}
}
