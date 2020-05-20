variable "tags" {
    type = map
    default = {
        Environment = "Production"
    }
}

variable "devops_objectids" {
    type = map(object({
        object_id = string
    }))

    default = {
        TerryCain = { object_id = "f7c46488-2054-46de-9673-e0c6e94b232c" },
        ChrisPressland = { object_id = "48aca6b1-4d56-4a15-bc92-8aa9d97300df" },
        TomWinchester = { object_id = "de80162c-8e52-466b-affd-f3ccc0a66d5d" },
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
