variable "users" {
  type = map(object({
    name          = string
    job_title     = string
    manager       = optional(string, null)
    email_aliases = optional(list(string), null)
    enabled       = optional(bool, true)
  }))
  default = {}
}

locals {
  managers = [for user in var.users : "${user.manager}@bink.com" if user.manager != null]
}

data "azuread_user" "manager" {
  for_each            = toset(local.managers)
  user_principal_name = each.value
}

output "managers" {
  value = data.azuread_user.manager
}

resource "random_password" "entra_user_temporary_password" {
  for_each = var.users
  length   = 32
  special  = true
  lower    = true
  upper    = true
  numeric  = true
}

resource "azuread_user" "i" {
  for_each            = var.users
  display_name        = each.value.name
  user_principal_name = "${each.key}@bink.com"
  manager_id          = each.value.manager != null ? data.azuread_user.manager["${each.value.manager}@bink.com"].id : null
  password            = random_password.entra_user_temporary_password[each.key].result
  account_enabled     = each.value.enabled

  lifecycle {
    ignore_changes = [
      password,
    ]
  }
}
