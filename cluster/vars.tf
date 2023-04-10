variable "common" {
    type = object({
        name = string
        location = string
        cidr = string
    })
}

variable "firewall" {
    type = object({
        resource_group_name = string
        vnet_name = string
        vnet_id = string
        ip = string
    })
    default = {
        resource_group_name = "uksouth-firewall"
        ip = "192.168.0.4"
        vnet_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-firewall/providers/Microsoft.Network/virtualNetworks/firewall-vnet"
        vnet_name = "firewall-vnet"
    }
}

variable "managed_identities" {
    type = map(object({
        assigned_to = list(string)
    }))
}

variable "iam" {
    type = map(object({
        assigned_to = list(string)
    }))
}

variable "loganalytics" {
    type = object({
        enabled = bool
        sku = optional(string, "PerGB2018")
        retention_in_days = optional(number, 30)
    })
}

variable "keyvault" {
    type = object({
        enabled = bool
    })
}

variable "storage" {
    type = object({
        enabled = bool
        rules = optional(list(object({
            name = string
            prefix_match = list(string)
            delete_after_days = number
        })), [])
    })
}

variable "postgres" {
    type = object({
        enabled = bool
        sku = optional(string, "GP_Standard_D2ds_v4")
        version = optional(number, 14)
        storage_mb = optional(number, 131072)
        ha = optional(bool, false)
        databases = optional(list(string), [
            "api_reflector",
            "atlas",
            "carina",
            "cosmos",
            "eos",
            "europa",
            "hades",
            "harmonia",
            "helios",
            "hermes",
            "midas",
            "polaris",
            "pontus",
            "postgres",
            "snowstorm",
            "vela",
            "zagreus"
        ])
    })
}

variable "redis" {
    type = object({
        enabled = bool
    })
}

variable "kube" {
    type = object({
        enabled = bool
        flux_enabled = optional(bool, true)
        automatic_channel_upgrade = optional(string, "rapid")
        sku_tier = optional(string, "Free")
        pool_min_count = optional(number, 3)
        pool_max_count = optional(number, 10)
        pool_vm_size = optional(string, "Standard_E4ads_v5")
        pool_zones = optional(list(string), ["1","2","3"])
        pool_os_disk_type = optional(string, "Ephemeral")
        pool_os_sku = optional(string, "Mariner")
        authorized_ip_ranges = optional(list(string))
        aad_admin_group_object_ids = optional(list(string), ["0140ccf4-f68c-4daa-b531-97e5292ec364"])
        maintenance_day = optional(string, "Monday")
    })
}
