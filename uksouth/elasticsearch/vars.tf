variable "private_dns_link_bink_host" {}
variable "private_dns_link_bink_sh" {}
variable "eventhub_logs" {}

variable environment { default = "elasticsearch" }
variable resource_group_name { default = "uksouth-elasticsearch" }
variable address_space { default = "192.168.3.0/24" }

variable "tags" {
    type = map
    default = {
        Environment = "Core"
    }
}
variable cluster_size { default = 3 }
variable vm_size { default = "Standard_D4s_v4" }
