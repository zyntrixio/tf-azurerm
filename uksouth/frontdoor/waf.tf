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
            match_values = ["/admin"]
        }
        match_condition {
            match_variable     = "RemoteAddr"
            operator           = "IPMatch"
            negation_condition = true
            match_values       = ["194.74.152.11"]
        }
    }
}
