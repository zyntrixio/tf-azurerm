terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 1.3.3"
}

locals {
  private_link_ids = {
    "uksouth_prod" = "/subscriptions/42706d13-8023-4b0c-b98a-1a562cb9ac40/resourceGroups/uksouth-prod-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-prod"
  }

  origin_groups = {
    "uksouth_prod_bpl" = {
      "endpoint"         = "uksouth-prod"
      "domain"           = "bpl.gb.bink.com"
      "cached_endpoints" = ["/content/*"]
      "cert_name"        = "acmebot-gb-bink-com"
      "origins"          = { "bpl.prod.uksouth.bink.sh" = { "id" = local.private_link_ids.uksouth_prod } }
    }
    "uksouth_prod_rewards" = {
      "endpoint"         = "uksouth-prod"
      "domain"           = "rewards.gb.bink.com"
      "cached_endpoints" = ["/content/*"]
      "cert_name"        = "acmebot-gb-bink-com"
      "origins"          = { "rewards.prod.uksouth.bink.sh" = { "id" = local.private_link_ids.uksouth_prod } }
    }
    "uksouth_prod_policies" = {
      "endpoint"  = "uksouth-prod"
      "domain"    = "policies.gb.bink.com"
      "cert_name" = "acmebot-gb-bink-com"
      "origins"   = { "policies.prod.uksouth.bink.sh" = { "id" = local.private_link_ids.uksouth_prod } }
    }
    "uksouth_prod_tableau" = {
      "endpoint"  = "uksouth-prod"
      "domain"    = "tableau.gb.bink.com"
      "cert_name" = "acmebot-gb-bink-com"
      "origins"   = { "tableau.prod.uksouth.bink.sh" = { "id" = local.private_link_ids.uksouth_prod } }
    }
    "uksouth_prod_docs" = {
      "endpoint"  = "uksouth-prod"
      "domain"    = "docs.gb.bink.com"
      "cert_name" = "acmebot-gb-bink-com"
      "origins"   = { "docs.prod.uksouth.bink.sh" = { "id" = local.private_link_ids.uksouth_prod } }
    }
    "uksouth_prod_api" = {
      "endpoint"         = "uksouth-prod"
      "domain"           = "api.gb.bink.com"
      "cached_endpoints" = ["/content/*"]
      "cert_name"        = "acmebot-gb-bink-com"
      "origins"          = { "api.prod.uksouth.bink.sh" = { "id" = local.private_link_ids.uksouth_prod } }
    }
    "uksouth_prod_portal" = {
      "endpoint"  = "uksouth-prod"
      "domain"    = "portal.gb.bink.com"
      "cert_name" = "acmebot-gb-bink-com"
      "origins"   = { "portal.prod.uksouth.bink.sh" = { "id" = local.private_link_ids.uksouth_prod } }
    }
    "uksouth_prod_retailer" = {
      "endpoint"  = "uksouth-prod"
      "domain"    = "retailer.gb.bink.com"
      "cert_name" = "acmebot-gb-bink-com"
      "origins"   = { "retailer.prod.uksouth.bink.sh" = { "id" = local.private_link_ids.uksouth_prod } }
    }
  }

  endpoints = distinct([for og in local.origin_groups : og.endpoint])
  origins = merge(flatten(([
    for group_key, group_value in local.origin_groups : {
      for origin_key, origin_value in group_value.origins :
      "${group_key}-${origin_key}" => {
        "domain"       = origin_key,
        "origin_group" = group_key,
        "id"           = origin_value.id,
      }
    }
  ]))...)

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

resource "azurerm_cdn_frontdoor_rule_set" "standard" {
  name                     = "standard"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id
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

resource "azurerm_cdn_frontdoor_endpoint" "i" {
  for_each                 = toset(local.endpoints)
  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id
}

resource "azurerm_cdn_frontdoor_custom_domain" "i" {
  for_each                 = local.origin_groups
  name                     = replace(each.value.domain, ".", "-")
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id
  dns_zone_id              = var.common.dns_zone.id
  host_name                = each.value.domain

  tls {
    certificate_type        = "CustomerCertificate"
    minimum_tls_version     = "TLS12"
    cdn_frontdoor_secret_id = azurerm_cdn_frontdoor_secret.i[each.value.cert_name].id
  }
}

resource "azurerm_dns_cname_record" "i" {
  for_each            = local.origin_groups
  name                = trimsuffix(each.value.domain, ".bink.com")
  zone_name           = var.common.dns_zone.name
  resource_group_name = var.common.dns_zone.resource_group
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.i[each.value.endpoint].host_name
}

resource "azurerm_cdn_frontdoor_origin_group" "i" {
  for_each                 = local.origin_groups
  name                     = replace(each.key, "_", "-")
  session_affinity_enabled = false
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "i" {
  for_each                      = local.origins
  name                          = replace(each.value.domain, ".", "-")
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.i[each.value.origin_group].id
  enabled                       = true

  certificate_name_check_enabled = true

  host_name          = each.value.domain
  origin_host_header = each.value.domain
  priority           = 1
  weight             = 1
  private_link {
    request_message        = "Request access for Private Link Origin CDN Frontdoor"
    location               = var.common.location
    private_link_target_id = each.value.id
  }
}

resource "azurerm_cdn_frontdoor_route" "i" {
  for_each                      = local.origin_groups
  name                          = replace(each.key, "_", "-")
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.i[each.value.endpoint].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.i[each.key].id
  cdn_frontdoor_origin_ids = [
    for k, v in each.value.origins : azurerm_cdn_frontdoor_origin.i["${each.key}-${k}"].id
  ]
  cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.standard.id]
  enabled                    = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.i[each.key].id]
  link_to_default_domain          = false
}

resource "azurerm_cdn_frontdoor_route" "cache" {
  for_each                      = { for key, value in local.origin_groups : key => value if can(value.cached_endpoints) }
  name                          = "${replace(each.key, "_", "-")}-cached"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.i[each.value.endpoint].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.i[each.key].id
  cdn_frontdoor_origin_ids = [
    for k, v in each.value.origins : azurerm_cdn_frontdoor_origin.i["${each.key}-${k}"].id
  ]
  cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.standard.id]
  enabled                    = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = each.value.cached_endpoints
  supported_protocols    = ["Http", "Https"]

  cache {
    query_string_caching_behavior = "UseQueryString"
    compression_enabled           = false
  }

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.i[each.key].id]
  link_to_default_domain          = false
}

output "profile" {
  value = azurerm_cdn_frontdoor_profile.i.id
}

output "certificates" {
  value = { for k, v in azurerm_cdn_frontdoor_secret.i : k => v.id }
}
