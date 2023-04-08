variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "bink_sh_managed_identities" {
    type = map
    default = {}
}
