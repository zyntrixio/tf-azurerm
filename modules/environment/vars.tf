variable resource_group_name { type = string }
variable location { type = string }
variable tags { type = map }

variable keyvault_users {
    type = map(object({ object_id = string }))
    default = {}
}
variable postgres_config {
    type = map
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
