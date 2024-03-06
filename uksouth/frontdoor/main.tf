terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 1.3.3"
}

locals {
  kv_certs = toset([
    "acmebot-gb-bink-com",
    "acmebot-staging-gb-bink-com",
    "acmebot-sandbox-gb-bink-com",
    "acmebot-lloyds-gb-bink-com",
    "acmebot-retail-gb-bink-com",
    "acmebot-perf-gb-bink-com",
  ])
}

variable "common" {
  type = object({
    location                 = optional(string, "uksouth")
    loganalytics_id          = string
    response_timeout_seconds = optional(number, 60)
    log_iam                  = optional(list(string), [])
    secure_origins = object({
      ipv4      = list(string)
      ipv6      = list(string)
      checkly   = optional(list(string), ["167.172.61.234/32", "167.172.53.20/32"])
      tailscale = optional(list(string), [])
    })
    dns_zone = object({
      id             = string
      name           = string
      resource_group = string
    })
    key_vault = object({
      sku_name         = optional(string, "standard")
      cdn_object_id    = optional(string, "602c4504-db34-4004-bd0a-dbdf556784dd")
      tf_object_id     = optional(string, "4869640a-3727-4496-a8eb-f7fae0872410")
      admin_object_ids = optional(map(string), {})
      admin_ips        = optional(list(string), [])
    })
  })
}

data "azurerm_client_config" "i" {}

resource "azurerm_resource_group" "i" {
  name     = "${var.common.location}-frontdoor"
  location = var.common.location
}

resource "azurerm_log_analytics_workspace" "i" {
  name                = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_role_assignment" "log_iam" {
  for_each             = toset(var.common.log_iam)
  scope                = azurerm_log_analytics_workspace.i.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = each.key
}

resource "azurerm_key_vault" "i" {
  name                          = "bink-${azurerm_resource_group.i.name}"
  resource_group_name           = azurerm_resource_group.i.name
  location                      = azurerm_resource_group.i.location
  sku_name                      = var.common.key_vault.sku_name
  tenant_id                     = data.azurerm_client_config.i.tenant_id
  public_network_access_enabled = true
}

resource "azurerm_key_vault_access_policy" "i" {
  for_each = merge(var.common.key_vault.admin_object_ids, {
    "terraform" = var.common.key_vault.tf_object_id
  })
  key_vault_id = azurerm_key_vault.i.id

  tenant_id = data.azurerm_client_config.i.tenant_id
  object_id = each.value

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get",
    "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts",
    "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]
  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}

resource "azurerm_key_vault_access_policy" "cdn" {
  key_vault_id = azurerm_key_vault.i.id

  tenant_id = data.azurerm_client_config.i.tenant_id
  object_id = var.common.key_vault.cdn_object_id

  secret_permissions = ["Get"]
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = "binkuksouthlogs"
  target_resource_id         = azurerm_key_vault.i.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.i.id

  enabled_log { category = "AuditEvent" }
  enabled_log { category = "AzurePolicyEvaluationDetails" }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

data "azurerm_key_vault_certificate" "i" {
  for_each     = local.kv_certs
  name         = split(".", each.key)[0]
  key_vault_id = azurerm_key_vault.i.id
}

resource "azurerm_cdn_frontdoor_profile" "i" {
  name                     = azurerm_resource_group.i.name
  resource_group_name      = azurerm_resource_group.i.name
  response_timeout_seconds = var.common.response_timeout_seconds
  sku_name                 = "Premium_AzureFrontDoor"
}

resource "azurerm_monitor_diagnostic_setting" "afd" {
  name                       = "binkuksouthlogs"
  target_resource_id         = azurerm_cdn_frontdoor_profile.i.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.i.id

  enabled_log { category = "FrontDoorAccessLog" }
  enabled_log { category = "FrontDoorHealthProbeLog" }
  enabled_log { category = "FrontDoorWebApplicationFirewallLog" }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

resource "azurerm_cdn_frontdoor_secret" "i" {
  for_each                 = data.azurerm_key_vault_certificate.i
  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

  secret {
    customer_certificate {
      key_vault_certificate_id = each.value.versionless_id
    }
  }
}

output "profile" {
  value = azurerm_cdn_frontdoor_profile.i.id
}

output "certificates" {
  value = { for k, v in azurerm_cdn_frontdoor_secret.i : k => v.id }
}
