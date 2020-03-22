variable environment { default = "monitoring" }

variable subnet_address_prefixes {
  default = [
    "192.168.6.0/28",  # Kibana
    "192.168.6.16/28", # Elasticsearch
    "192.168.6.32/28", # Grafana
    "192.168.6.48/28", # Alertmanager
    "192.168.6.64/28", # Prometheus
    "192.168.6.80/28"  # Argus
  ]
}

variable "tags" {
  type = map
  default = {
    Environment = "Production"
  }
}

variable elasticsearch_vm_size { default = "Standard_D4s_v3" }
variable elasticsearch_count { default = 3 }
variable kibana_vm_size { default = "Standard_D2s_v3" }
variable kibana_count { default = 1 }
variable argus_vm_size { default = "Standard_D2s_v3" }
variable argus_count { default = 1 }