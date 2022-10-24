resource "azurerm_dns_zone" "bink-sh" {
    name = "bink.sh"
    resource_group_name = azurerm_resource_group.rg.name
}

locals {
    bink_sh = {
        a_records = {
            "ssh.uksouth" = "51.132.44.240"
            "sftp.dev.uksouth" = "51.132.44.242"
            "wg.uksouth" = "51.132.44.249"
            "wireguard.uksouth" = "51.105.20.158" # TODO: Move this into Wireguard module
            "tableau.uksouth" = "51.132.44.253"
            "opensearch.uksouth" = "51.132.44.255"
            "ara.do" = "134.209.178.119"
        }
        cname_records = {
            "autodiscover" = "autodiscover.outlook.com"
        }
        mx_records = {
            "@" = [
                {
                    preference = 0,
                    exchange = "bink-sh.mail.protection.outlook.com",
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

resource "azurerm_dns_a_record" "bink_sh_a" {
    for_each = local.bink_sh.a_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = [each.value]
}

resource "azurerm_dns_cname_record" "bink_sh_cname" {
    for_each = local.bink_sh.cname_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    record = each.value
}

resource "azurerm_dns_mx_record" "bink_sh_mx" {
    for_each = local.bink_sh.mx_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-sh.name
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

resource "azurerm_dns_srv_record" "bink_sh_srv" {
    for_each = local.bink_sh.srv_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300

    record {
        priority = each.value["priority"]
        weight = each.value["weight"]
        port = each.value["port"]
        target = each.value["target"]
    }
}

resource "azurerm_dns_txt_record" "bink_sh_txt" {
    for_each = local.bink_sh.txt_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-sh.name
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

resource "azurerm_dns_caa_record" "root" {
    name = "@"
    zone_name = azurerm_dns_zone.bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 3600

    record {
        flags = 0
        tag = "issue"
        value = "letsencrypt.org"
    }

    record {
        flags = 0
        tag = "issuewild"
        value = "letsencrypt.org"
    }

    record {
        flags = 0
        tag = "iodef"
        value = "mailto:devops@bink.com"
    }
}
