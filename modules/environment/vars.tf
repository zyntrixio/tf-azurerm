variable resource_group_name { type = string }
variable location { type = string }
variable tags { type = map }

variable resource_group_iam {
    type = map
    default = {}
}

variable keyvault_users {
    type = map(object({ object_id = string }))
    default = {}
}
variable postgres_config {
    type = map(object({
        name = string
        databases = list(string)
        sku_name = string
        storage_gb = number
    }))
    default = {}
}
variable redis_config {
    type = map
    default = {}
}
variable storage_config {
    type = map
    default = {}
}
