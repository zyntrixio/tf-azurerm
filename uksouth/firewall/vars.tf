variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "sentry_vnet_id" {}
variable "tableau_vnet_id" {}
variable "tools_vnet_id" {}
variable "sentry_ip_address" {}
variable "tableau_ip_address" {}
variable "bastion_ip_address" {}

variable "secure_origins" {
    type = list
    default = [
        "194.74.152.11/32", # Ascot Bink HQ
        "217.169.3.233/32", # cpressland@bink.com
        "81.2.99.144/29", # cpressland@bink.com
        "82.13.29.15/32", # twinchester@bink.com
        "86.28.118.165/32" # tcain@bink.com
    ]
}
