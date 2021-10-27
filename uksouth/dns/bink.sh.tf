resource "azurerm_dns_zone" "bink-sh" {
    name = "bink.sh"
    resource_group_name = azurerm_resource_group.rg.name
}

locals {
    bink_sh = {
        a_records = {
            "prometheus.uksouth" = "51.132.44.251"
            "ssh.uksouth" = "51.132.44.240"
            "jeff" = "217.169.3.233"
            "policies.uksouth" = "51.132.44.240" # ???????????????????????????????????
            "sftp.dev.uksouth" = "51.132.44.242"
            "chef.uksouth" = "51.132.44.240"
            "wg.uksouth" = "51.132.44.249"
            "starbug.uksouth" = "51.132.44.240"
            "sentry.uksouth" = "51.132.44.254"
            "sftp.staging.uksouth" = "51.132.44.241"
            "sandbox.k8s.uksouth" = "51.132.44.243"
            "wireguard.uksouth" = "20.49.163.188"
            "tableau.uksouth" = "51.132.44.253"
            "tools.k8s.uksouth" = "51.132.44.244"
        }
        cname_records = {
            "mobsf.uksouth" = "tools0.uksouth.bink.sh"
            "kibana.uksouth" = "tools0.uksouth.bink.sh"
            "autodiscover" = "autodiscover.outlook.com"
            "cluster-autodiscover.uksouth" = "tools0.uksouth.bink.sh"
            "grafana.tools" = "tools0.uksouth.bink.sh"
            "asset-register.tools" = "tools0.uksouth.bink.sh"
            "bridge.uksouth" = "tools0.uksouth.bink.sh"
            "tools.uksouth" = "tools0.uksouth.bink.sh"
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
