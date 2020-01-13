variable environment { default = "efk" }
variable location { default = "uksouth" }
variable resource_group_name { default = "uksouth-efk" }

variable subnet_address_prefixes {
  default = [
    "192.168.6.0/25",   # Kibana
    "192.168.6.128/25" # Elasticsearch
  ]
}
variable elasticsearch_vm_size { default = "Standard_D4s_v3" }
variable elasticsearch_count { default = 3 }
variable kibana_vm_size { default = "Standard_D2s_v3" }
variable kibana_count { default = 1 }
