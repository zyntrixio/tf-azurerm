variable "groups" {
  type = map(object({
    description  = string
    roles        = optional(list(string), ["owner", "contributor", "reader"])
    environments = optional(list(string), ["non-production", "production"])
  }))
  default = {}
}

locals {
  groups = merge(flatten([
    for k, v in var.groups : [
      for role in v.roles : [
        for env in v.environments : {
          "${env}_${k}_${role}" = {
            name        = "${title(env)} - ${title(replace(k, "_", " "))} - ${title(role)}"
            description = v.description
          }
        }
      ]
    ]
  ])...)
}

resource "azuread_group" "i" {
  for_each           = local.groups
  display_name       = each.value.name
  description        = each.value.description
  security_enabled   = true
  assignable_to_role = true
}

output "groups" {
  value = azuread_group.i
}
