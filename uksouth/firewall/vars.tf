variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "tableau_vnet_id" {}
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
