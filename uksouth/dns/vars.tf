variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "vpn_ips" {
    description = "Defines IP Addresses for VPN Servers on vpn.gb.bink.com"
    type = object({
      ipv4 = optional(list(string))
      ipv6 = optional(list(string))
    })
    default = {}
}
