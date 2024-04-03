variable "common" {
  type = object({
    name     = string
    location = string
    cidr     = string
  })
}

variable "allowed_hosts" {
  type = object({
    ipv4 = list(string),
    ipv6 = list(string),
  })
}

variable "frontdoor" {
  type = object({
    profile = optional(string, "")
    domains = optional(map(object({
      certificate = string
      origin_fqdn = string
      waf = optional(object({
        enforced = optional(bool, false)
        custom_rules = optional(map(object({
          enabled = optional(bool, true)
          action  = optional(string, "Block")
          match_conditions = list(object({
            match_variable     = string
            operator           = string
            match_values       = list(string)
            negation_condition = optional(bool, false)
          }))
        })), {})
        managed_rules = optional(map(object({
          version = string
          action  = string
        })), {})
      }), {})
    })), {})
  })
  default = {}
}

variable "grafana_id" {
  type    = string
  default = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-grafana/providers/Microsoft.Dashboard/grafana/uksouth-grafana"
}

variable "tailscale" {
  type = object({
    client_id     = string
    client_secret = string
  })
  default = {
    client_id     = "kc7cDo5CNTRL",
    client_secret = "tskey-client-kc7cDo5CNTRL-eKbaiSFA7FKzrBcaTaFxEKvgrkNHFFKvR"
  }
}

variable "backups" {
  type = object({
    resource_id  = string
    principal_id = string
    policies = object({
      blob_storage = string,
      postgres     = string,
    })
  })
}

variable "firewall" {
  type = object({
    resource_group_name = string
    vnet_name           = string
    vnet_id             = string
    ip                  = string
    v4_prefix           = string
  })
  default = {
    resource_group_name = "uksouth-firewall"
    ip                  = "192.168.0.4"
    vnet_id             = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-firewall/providers/Microsoft.Network/virtualNetworks/firewall-vnet"
    vnet_name           = "firewall-vnet"
    v4_prefix           = "51.132.44.240/28"
  }
}

variable "managed_identities" {
  type = map(object({
    assigned_to = optional(list(string), [])
    namespaces  = optional(list(string), ["default"])
  }))
}

variable "iam" {
  type = map(object({
    assigned_to = list(string)
  }))
}

variable "loganalytics" {
  type = object({
    sku               = optional(string, "PerGB2018")
    retention_in_days = optional(number, 30)
  })
  default = {}
}

variable "dns" {
  type = object({
    id                  = string
    zone_name           = string
    resource_group_name = string
  })
}

variable "acr" {
  type = object({
    id = string
  })
}

variable "storage" {
  type = object({
    sftp_enabled = bool
    rules = optional(list(object({
      name              = string
      prefix_match      = list(string)
      delete_after_days = number
    })), [])
  })
}

variable "postgres" {
  type = object({
    sku                   = optional(string, "GP_Standard_D2ds_v4")
    version               = optional(number, 15)
    storage_mb            = optional(number, 131072)
    ha                    = optional(bool, false)
    backup_retention_days = optional(number, 7)
    databases             = optional(list(string), [])
    entra_id_admins       = optional(list(object({ object_id = string, mail = string })), [])
  })
}

variable "redis" {
  type = object({
    enabled  = bool
    capacity = optional(number, 0)
    family   = optional(string, "C")
    sku_name = optional(string, "Basic")
  })
}

variable "cloudamqp" {
  type = object({
    enabled = optional(bool, false)
    plan    = optional(string, "squirrel-1")
    region  = optional(string, "azure-arm::uksouth")
    vpc_id  = optional(string)
    subnet  = optional(string, "192.168.1.0/24")
  })
  default = {}
}

variable "tableau" {
  type = object({
    enabled = optional(bool, false)
    size    = optional(string, "Standard_E16as_v5")
  })
  default = {}
}

variable "kube" {
  type = object({
    flux_enabled               = optional(bool, true)
    automatic_channel_upgrade  = optional(string, "rapid")
    node_os_channel_upgrade    = optional(string, "NodeImage")
    sku_tier                   = optional(string, "Free")
    pool_min_count             = optional(number, 1)
    pool_max_count             = optional(number, 10)
    pool_vm_size               = optional(string, "Standard_D4ads_v5")
    pool_zones                 = optional(list(string), ["1", "2", "3"])
    pool_os_disk_type          = optional(string, "Ephemeral")
    ebpf_enabled               = optional(bool, false)
    pool_os_disk_size_gb       = optional(number, 128)
    pool_os_sku                = optional(string, "AzureLinux")
    pool_max_pods              = optional(number, 50)
    aad_admin_group_object_ids = optional(list(string), ["0140ccf4-f68c-4daa-b531-97e5292ec364"])
    maintenance_day            = optional(string, "Monday")
    additional_node_pools = optional(map(object({
      vm_size             = optional(string, "Standard_D4ads_v5")
      node_count          = optional(number)
      node_labels         = optional(map(string), { "kubernetes.azure.com/scalesetpriority" = "spot" })
      node_taints         = optional(list(string), ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"])
      max_count           = optional(number, 10)
      min_count           = optional(number, 0)
      enable_auto_scaling = optional(bool, true)
      priority            = optional(string, "Spot")
      spot_max_price      = optional(string, "-1")
      os_sku              = optional(string, "AzureLinux")
      max_pods            = optional(number, 50)
      os_disk_type        = optional(string, "Ephemeral")
      os_disk_size_gb     = optional(number, 128)
      zones               = optional(list(string), ["1", "2", "3"])
    })), {})
  })
}
