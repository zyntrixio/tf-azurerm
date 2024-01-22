variable "groups" {
  type = map(object({
    name        = string
    description = optional(string, null)
    members     = optional(list(string), null)
  }))
  default = {}
}

locals {
  group_members = merge([
    for group_key, group_value in var.groups : {
      for member_key in group_value.members : "${group_key}-${member_key}" => {
        group  = group_key
        member = member_key
      }
    }
  ]...)
}

resource "azuread_group" "i" {
  for_each         = var.groups
  display_name     = each.value.name
  description      = each.value.description
  security_enabled = true
}

resource "azuread_group_member" "i" {
  for_each         = local.group_members
  group_object_id  = azuread_group.i[each.value.group].id
  member_object_id = azuread_user.i[each.value.member].id
}
