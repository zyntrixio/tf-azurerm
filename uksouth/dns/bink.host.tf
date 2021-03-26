resource "azurerm_dns_zone" "bink-host" {
    name = "bink.host"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "uksouth-bink-host" {
    name = "uksouth.bink.host"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "aqua-uksouth-bink-host" {
    name = "aqua"
    zone_name = azurerm_private_dns_zone.uksouth-bink-host.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.5.0.4"]
}

locals {
    bink_host = {
        cname_records = {
            "autodiscover" = "autodiscover.outlook.com",
        }
        mx_records = {
            "@" = [
                {
                    preference = 0,
                    exchange = "bink-host.mail.protection.outlook.com",
                }
            ]
        }
        txt_records = {
            "@" = [
                "v=spf1 include:spf.protection.outlook.com -all",
                "MS=ms43009780",
            ]
        }
    }
}

resource "azurerm_dns_cname_record" "bink_host_cname" {
    for_each = local.bink_host.cname_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-host.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    record = each.value
}

resource "azurerm_dns_mx_record" "bink_host_mx" {
    for_each = local.bink_host.mx_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-host.name
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

resource "azurerm_dns_txt_record" "bink_host_txt" {
    for_each = local.bink_host.txt_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-host.name
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
