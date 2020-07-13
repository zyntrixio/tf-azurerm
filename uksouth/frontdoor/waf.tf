resource "azurerm_frontdoor_firewall_policy" "policy" {
  name                              = "policy"
  resource_group_name               = azurerm_resource_group.rg.name
  enabled                           = false
  mode                              = "Prevention"
  custom_block_response_status_code = 403
  custom_block_response_body        = "eyJlcnJvciI6ICJBY2Nlc3MgRGVuaWVkIiwgImV4cGxhbmF0aW9uIjogImh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3dhdGNoP3Y9ZFF3NHc5V2dYY1EifQo="

  custom_rule {
    name                           = "DjangoAdmin"
    enabled                        = false
    priority                       = 1
    type                           = "MatchRule"
    action                         = "Log"

    match_condition {
      match_variable     = "RequestUri"
      operator           = "Contains"
      match_values       = ["/admin"]
    }
  }
}
