variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "bastion_ip_address" {}
variable "sftp_ip_address" {}

variable "secure_origins" {
    type = list
    default = []
}

variable "loganalytics_id" {
    type = string
}
