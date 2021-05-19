resource "azurerm_dns_zone" "trenette_co_uk" {
    name = "trenette.co.uk"
    resource_group_name = azurerm_resource_group.rg.name
}

locals {
    trenette_co_uk = {
        a_records = {}
        cname_records = {
            "afdverify" = "afdverify.bink-frontdoor.azurefd.net"
        }
        mx_records = {}
        srv_records = {}
        txt_records = {}
    }
}

resource "azurerm_dns_cname_record" "trenette_co_uk_cname" {
    for_each = local.trenette_co_uk.cname_records

    name = each.key
    zone_name = azurerm_dns_zone.trenette_co_uk.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    record = each.value
}


resource "azurerm_dns_a_record" "apex_afd" {
    name = "@"
    zone_name = azurerm_dns_zone.trenette_co_uk.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    target_resource_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/frontdoor/providers/Microsoft.Network/frontdoors/bink-frontdoor"
}
