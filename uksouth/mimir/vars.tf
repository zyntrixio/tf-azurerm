variable "cidr" {
    type = string
    default = "10.50.0.0/16"
}

variable "peering" { type = map }
variable "automatic_channel_upgrade" { default = "stable" }
variable "sku_tier" { default = "Free" }
variable "node_count" {
    type = number
    default = 3
}
variable "node_size" {
    type = string
    default = "Standard_D2s_v4"
}
