variable name { type = string }
variable rg_name { type = string }
variable rg_location { type = string }
variable tags {}

variable "devops_objectids" {
    type = map(object({ object_id = string }))

    default = {
        DevOps = { object_id = "aac28b59-8ac3-4443-bccc-3fb820165a08" },
    }
}

variable "devops_keyvault_secretperms" {
    type = list(string)
    default = [
        "backup",
        "delete",
        "get",
        "list",
        "purge",
        "recover",
        "restore",
        "set",
    ]
}
