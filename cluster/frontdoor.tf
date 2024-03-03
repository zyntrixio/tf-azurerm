data "azurerm_private_link_service" "i" {
  count               = length(var.frontdoor.domains) > 0 ? 1 : 0
  name                = azurerm_resource_group.i.name
  resource_group_name = azurerm_kubernetes_cluster.i.node_resource_group
}

resource "azurerm_cdn_frontdoor_endpoint" "i" {
  provider                 = azurerm.core
  count                    = length(var.frontdoor.domains) > 0 ? 1 : 0
  name                     = azurerm_resource_group.i.name
  cdn_frontdoor_profile_id = var.frontdoor.profile
}

resource "azurerm_cdn_frontdoor_rule_set" "i" {
  provider                 = azurerm.core
  count                    = length(var.frontdoor.domains) > 0 ? 1 : 0
  name                     = replace(azurerm_resource_group.i.name, "-", "")
  cdn_frontdoor_profile_id = var.frontdoor.profile
}

resource "azurerm_cdn_frontdoor_rule" "cache_png" {
  provider                  = azurerm.core
  count                     = length(var.frontdoor.domains) > 0 ? 1 : 0
  name                      = "cachePNG"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.i[0].id
  order                     = 1
  behavior_on_match         = "Continue"

  conditions {
    url_file_extension_condition {
      operator     = "Contains"
      transforms   = ["Lowercase"]
      match_values = ["png"]
    }
  }

  actions {
    route_configuration_override_action {
      query_string_caching_behavior = "IgnoreQueryString"
      compression_enabled           = false
      cache_behavior                = "OverrideAlways"
      cache_duration                = "08:00:00"
    }
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "i" {
  provider                 = azurerm.core
  for_each                 = var.frontdoor.domains
  name                     = replace(each.key, ".", "-")
  cdn_frontdoor_profile_id = var.frontdoor.profile
  dns_zone_id              = var.dns.id
  host_name                = each.key

  tls {
    certificate_type        = "CustomerCertificate"
    minimum_tls_version     = "TLS12"
    cdn_frontdoor_secret_id = each.value.certificate
  }
}

resource "azurerm_dns_cname_record" "i" {
  provider            = azurerm.core
  for_each            = var.frontdoor.domains
  name                = trimsuffix(each.key, ".bink.com")
  zone_name           = var.dns.zone_name
  resource_group_name = var.dns.resource_group_name
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.i[0].host_name
}

resource "azurerm_cdn_frontdoor_origin_group" "i" {
  provider                 = azurerm.core
  for_each                 = var.frontdoor.domains
  name                     = replace(each.key, ".", "-")
  session_affinity_enabled = false
  cdn_frontdoor_profile_id = var.frontdoor.profile

  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "i" {
  provider                      = azurerm.core
  for_each                      = var.frontdoor.domains
  name                          = replace(each.value.origin_fqdn, ".", "-")
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.i[each.key].id
  enabled                       = true

  certificate_name_check_enabled = true

  host_name          = each.value.origin_fqdn
  origin_host_header = each.value.origin_fqdn
  priority           = 1
  weight             = 1
  private_link {
    request_message        = "Request access for Private Link Origin CDN Frontdoor"
    location               = azurerm_resource_group.i.location
    private_link_target_id = data.azurerm_private_link_service.i[0].id
  }
}

resource "azurerm_cdn_frontdoor_route" "i" {
  provider                      = azurerm.core
  for_each                      = var.frontdoor.domains
  name                          = replace(each.key, ".", "-")
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.i[0].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.i[each.key].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.i[each.key].id]
  cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.i[0].id]
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.i[each.key].id]
  link_to_default_domain          = false
}
