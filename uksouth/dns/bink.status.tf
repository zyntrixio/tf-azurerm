resource "azurerm_dns_zone" "bink-status" {
    name = "bink.status"
    resource_group_name = azurerm_resource_group.rg.name
}

locals {
    bink_status = {
        a_records = {
        }
        cname_records = {
        }
        mx_records = {
            "@" = [
                {
                    preference = 0,
                    exchange = "bink-status.mail.protection.outlook.com",
                }
            ]
        }
        srv_records = {}
        txt_records = {
            "@" = [
                "v=spf1 include:spf.protection.outlook.com -all",
                "apple-domain-verification=bgPRnFWwsHMbqgEx",
                "MS=ms96156124"
            ]
        }
    }
}

resource "azurerm_dns_a_record" "bink_status_a" {
    for_each = local.bink_status.a_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-status.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = [each.value]
}

resource "azurerm_dns_cname_record" "bink_status_cname" {
    for_each = local.bink_status.cname_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-status.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    record = each.value
}

resource "azurerm_dns_mx_record" "bink_status_mx" {
    for_each = local.bink_status.mx_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-status.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300

    dynamic "record" {
        for_each = [for i in each.value : {
            preference = i["preference"]
            exchange = i["exchange"]
        }]

        content {
            preference = record.value.preference
            exchange = record.value.exchange
        }
    }
}

resource "azurerm_dns_srv_record" "bink_status_srv" {
    for_each = local.bink_status.srv_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-status.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300

    record {
        priority = each.value["priority"]
        weight = each.value["weight"]
        port = each.value["port"]
        target = each.value["target"]
    }
}

resource "azurerm_dns_txt_record" "bink_status_txt" {
    for_each = local.bink_status.txt_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-status.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300

    dynamic "record" {
        for_each = [for i in each.value : {
            value = i
        }]

        content {
            value = record.value.value
        }
    }
}
