resource "azurerm_cdn_frontdoor_firewall_policy" "olympus" {
    name = "olympus"
    resource_group_name = azurerm_resource_group.i.name
    sku_name = azurerm_cdn_frontdoor_profile.i.sku_name
    enabled = true
    mode = "Prevention"
    custom_block_response_status_code = 403
    custom_block_response_body = "eyJlcnJvciI6ICJBY2Nlc3MgRGVuaWVkIiwgImV4cGxhbmF0aW9uIjogImh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3dhdGNoP3Y9ZFF3NHc5V2dYY1EifQo="

    custom_rule {
        name = "DjangoAdmin"
        enabled = true
        priority = 1
        type = "MatchRule"
        action = "Block"

        match_condition {
            match_variable = "RequestUri"
            operator = "Contains"
            match_values = ["/admin"]
        }
        match_condition {
            match_variable = "RemoteAddr"
            operator = "IPMatch"
            negation_condition = true
            match_values = concat(
                var.common.secure_origins.ipv4, var.common.secure_origins.ipv6, var.common.secure_origins.checkly
            )
        }
    }
}

resource "azurerm_cdn_frontdoor_security_policy" "olympus" {
    name = "olympus"
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

    security_policies {
        firewall {
            cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.olympus.id
            association {
                patterns_to_match = ["/*"]
                dynamic domain {
                    for_each = toset([
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_dev_api"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_api"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_perf_api"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_api"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_sandbox_lloyds_sit"].id,
                    ])
                    content {
                        cdn_frontdoor_domain_id = domain.key
                    }
                }
            }
        }
    }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "audit" {
    name = "audit"
    resource_group_name = azurerm_resource_group.i.name
    sku_name = azurerm_cdn_frontdoor_profile.i.sku_name
    enabled = true
    mode = "Prevention"
    custom_block_response_status_code = 403
    custom_block_response_body = "eyJlcnJvciI6ICJBY2Nlc3MgRGVuaWVkIiwgImV4cGxhbmF0aW9uIjogImh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3dhdGNoP3Y9ZFF3NHc5V2dYY1EifQo="

    custom_rule {
        name = "DefaultBlock"
        enabled = true
        priority = 1
        type = "MatchRule"
        action = "Block"

        match_condition {
            match_variable = "RequestUri"
            operator = "Contains"
            match_values = ["/"]
        }
        match_condition {
            match_variable = "RemoteAddr"
            operator = "IPMatch"
            negation_condition = true
            match_values = concat(
                var.common.secure_origins.ipv4, var.common.secure_origins.ipv6
            )
        }
    }
}

resource "azurerm_cdn_frontdoor_security_policy" "audit" {
    name = "audit"
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

    security_policies {
        firewall {
            cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.audit.id
            association {
                patterns_to_match = ["/*"]
                dynamic domain {
                    for_each = toset([
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_dev_audit"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_audit"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_audit"].id,
                    ])
                    content {
                        cdn_frontdoor_domain_id = domain.key
                    }
                }
            }
        }
    }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "bpl" {
    name = "bpl"
    resource_group_name = azurerm_resource_group.i.name
    sku_name = azurerm_cdn_frontdoor_profile.i.sku_name
    enabled = true
    mode = "Prevention"
    custom_block_response_status_code = 403
    custom_block_response_body = "eyJlcnJvciI6ICJBY2Nlc3MgRGVuaWVkIiwgImV4cGxhbmF0aW9uIjogImh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3dhdGNoP3Y9ZFF3NHc5V2dYY1EifQo="

    custom_rule {
        name = "EventHorizonAdmin"
        enabled = true
        priority = 1
        type = "MatchRule"
        action = "Block"

        match_condition {
            match_variable = "RequestUri"
            operator = "Contains"
            match_values = ["/admin"]
        }
        match_condition {
            match_variable = "RemoteAddr"
            operator = "IPMatch"
            negation_condition = true
            match_values = concat(
                var.common.secure_origins.ipv4, var.common.secure_origins.ipv6, var.common.secure_origins.checkly
            )
        }
    }

    custom_rule {
        name = "MarketingRateLimit"
        enabled = true
        priority = 2
        type = "RateLimitRule"
        action = "Block"
        rate_limit_duration_in_minutes = 1
        rate_limit_threshold = 15

        match_condition {
            match_variable = "RequestUri"
            operator = "Contains"
            match_values = ["/marketing/unsubscribe"]
        }
    }
}

resource "azurerm_cdn_frontdoor_security_policy" "bpl" {
    name = "bpl"
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

    security_policies {
        firewall {
            cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.bpl.id
            association {
                patterns_to_match = ["/*"]
                dynamic domain {
                    for_each = toset([
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_dev_bpl"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_bpl"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_bpl"].id,
                    ])
                    content {
                        cdn_frontdoor_domain_id = domain.key
                    }
                }
            }
        }
    }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "internal" {
    name = "internal"
    resource_group_name = azurerm_resource_group.i.name
    sku_name = azurerm_cdn_frontdoor_profile.i.sku_name
    enabled = true
    mode = "Prevention"
    custom_block_response_status_code = 403
    custom_block_response_body = "eyJlcnJvciI6ICJBY2Nlc3MgRGVuaWVkIiwgImV4cGxhbmF0aW9uIjogImh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3dhdGNoP3Y9ZFF3NHc5V2dYY1EifQo="

    custom_rule {
        name = "AllEndpoints"
        enabled = true
        priority = 1
        type = "MatchRule"
        action = "Block"

        match_condition {
            match_variable = "RequestUri"
            operator = "Contains"
            match_values = ["/"]
        }
        match_condition {
            match_variable = "RemoteAddr"
            operator = "IPMatch"
            negation_condition = true
            match_values = concat(
                var.common.secure_origins.ipv4, var.common.secure_origins.ipv6, var.common.secure_origins.checkly
            )
        }
    }
}

resource "azurerm_cdn_frontdoor_security_policy" "internal" {
    name = "internal"
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

    security_policies {
        firewall {
            cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.internal.id
            association {
                patterns_to_match = ["/*"]
                dynamic domain {
                    for_each = toset([
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_ait_starbug"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_dev_docs"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_dev_wallet"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_dev_wasabi"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_dev_retailer"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_kratos"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_docs"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_wallet"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_wasabi"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_airbyte"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_prefect"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_retailer"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_tableau_admin"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_airbyte"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_prefect"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_asset_register"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_bridge"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_prod_grafana"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_perf_locustv2"].id,
                    ])
                    content {
                        cdn_frontdoor_domain_id = domain.key
                    }
                }
            }
        }
    }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "api_reflector" {
    name = "apireflector"
    resource_group_name = azurerm_resource_group.i.name
    sku_name = azurerm_cdn_frontdoor_profile.i.sku_name
    enabled = true
    mode = "Prevention"
    custom_block_response_status_code = 403
    custom_block_response_body = "eyJlcnJvciI6ICJBY2Nlc3MgRGVuaWVkIiwgImV4cGxhbmF0aW9uIjogImh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3dhdGNoP3Y9ZFF3NHc5V2dYY1EifQo="

    custom_rule {
        name = "APIReflector"
        enabled = true
        priority = 1
        type = "MatchRule"
        action = "Block"

        match_condition {
            match_variable = "RequestUri"
            operator = "Contains"
            negation_condition = true
            match_values = ["/mock/"]
        }
        match_condition {
            match_variable = "RemoteAddr"
            operator = "IPMatch"
            negation_condition = true
            match_values = concat(
                var.common.secure_origins.ipv4, var.common.secure_origins.ipv6, var.common.secure_origins.checkly
            )
        }
    }
}

resource "azurerm_cdn_frontdoor_security_policy" "api_reflector" {
    name = "apireflector"
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

    security_policies {
        firewall {
            cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.api_reflector.id
            association {
                patterns_to_match = ["/*"]
                dynamic domain {
                    for_each = toset([
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_dev_reflector"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_staging_reflector"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_lloyds_reflector"].id,
                        azurerm_cdn_frontdoor_custom_domain.i["uksouth_perf_reflector"].id,
                    ])
                    content {
                        cdn_frontdoor_domain_id = domain.key
                    }
                }
            }
        }
    }
}
