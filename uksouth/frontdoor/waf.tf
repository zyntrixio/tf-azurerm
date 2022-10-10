resource "azurerm_frontdoor_firewall_policy" "policy" {
    name = "policy"
    resource_group_name = azurerm_resource_group.rg.name
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
            match_values = ["/admin", "/txm"]
        }
        match_condition {
            match_variable = "RemoteAddr"
            operator = "IPMatch"
            negation_condition = true
            match_values = concat(var.secure_origins, var.secure_origins_v6)
        }
    }

    custom_rule {
        name = "BPLRateLimit"
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

resource "azurerm_frontdoor_firewall_policy" "secure_origins" {
    name = "secureorigins"
    resource_group_name = azurerm_resource_group.rg.name
    enabled = true
    mode = "Prevention"
    custom_block_response_status_code = 403
    custom_block_response_body = "eyJlcnJvciI6ICJBY2Nlc3MgRGVuaWVkIiwgImV4cGxhbmF0aW9uIjogImh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3dhdGNoP3Y9ZFF3NHc5V2dYY1EifQo="

    custom_rule {
        name = "Everything"
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
            match_values = concat(var.secure_origins, var.secure_origins_v6, var.checkly_ips)
        }
    }
}
