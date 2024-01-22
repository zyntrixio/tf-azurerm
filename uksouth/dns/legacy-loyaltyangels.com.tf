resource "azurerm_dns_zone" "loyaltyangels_com" {
  name                = "loyaltyangels.com"
  resource_group_name = azurerm_resource_group.rg.name
}

locals {
  loyaltyangels_com = {
    cname_records = {
      "autodiscover"           = "autodiscover.outlook.com"
      "enterpriseenrollment"   = "enterpriseenrollment.manage.microsoft.com"
      "enterpriseregistration" = "enterpriseregistration.windows.net"
      "lyncdiscover"           = "webdir.online.lync.com"
      "msoid"                  = "clientconfig.microsoftonline-p.net"
      "sip"                    = "sipdir.online.lync.com"
    }
    mx_records = {
      "@" = [
        {
          preference = 0,
          exchange   = "loyaltyangels-com.mail.protection.outlook.com",
        }
      ]
    }
    srv_records = {
      "_sipfederationtls._tcp" = {
        priority = 100,
        weight   = 1,
        port     = 5061,
        target   = "sipfed.online.lync.com",
      }
      "_sip._tls" = {
        priority = 100,
        weight   = 1,
        port     = 443,
        target   = "sipdir.online.lync.com",
      }
    }
    txt_records = {
      "@" = [
        "v=spf1 include:spf.protection.outlook.com -all",
        "MS=ms89808407"
      ]
    }
  }
}

resource "azurerm_dns_cname_record" "loyaltyangels_com_cname" {
  for_each = local.loyaltyangels_com.cname_records

  name                = each.key
  zone_name           = azurerm_dns_zone.loyaltyangels_com.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record              = each.value
}

resource "azurerm_dns_mx_record" "loyaltyangels_com_mx" {
  for_each = local.loyaltyangels_com.mx_records

  name                = each.key
  zone_name           = azurerm_dns_zone.loyaltyangels_com.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  dynamic "record" {
    for_each = [for i in each.value : {
      preference = i["preference"]
      exchange   = i["exchange"]
    }]

    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}

resource "azurerm_dns_srv_record" "loyaltyangels_com_srv" {
  for_each = local.loyaltyangels_com.srv_records

  name                = each.key
  zone_name           = azurerm_dns_zone.loyaltyangels_com.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  record {
    priority = each.value["priority"]
    weight   = each.value["weight"]
    port     = each.value["port"]
    target   = each.value["target"]
  }
}

resource "azurerm_dns_txt_record" "loyaltyangels_com_txt" {
  for_each = local.loyaltyangels_com.txt_records

  name                = each.key
  zone_name           = azurerm_dns_zone.loyaltyangels_com.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  dynamic "record" {
    for_each = [for i in each.value : {
      value = i
    }]

    content {
      value = record.value.value
    }
  }
}
