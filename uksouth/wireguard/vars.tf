variable environment { default = "wireguard" }

variable "ip_range" { default = "192.168.0.0/24" }

variable "tags" {
    type = map
    default = {
        Environment = "Wireguard"
    }
}

variable "secure_origins" {
    type = list
    default = []
}
