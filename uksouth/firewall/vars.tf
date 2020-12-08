variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "sentry_vnet_id" {}
variable "tableau_vnet_id" {}
variable "sentry_ip_address" {}
variable "tableau_ip_address" {}
variable "bastion_ip_address" {}
variable "sftp_ip_address" {}

variable "secure_origins" {
    type = list
    default = []
}

variable "developer_ips" {
    type = list
    default = []
}
