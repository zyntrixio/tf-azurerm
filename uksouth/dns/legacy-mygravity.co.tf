resource "azurerm_dns_zone" "mygravity_co" {
  name                = "mygravity.co"
  resource_group_name = azurerm_resource_group.rg.name
}

locals {
  mygravity_co = {
    cname_records = {
      "autodiscover"           = "autodiscover.outlook.com"
      "email.info"             = "mailgun.org"
      "enterpriseenrollment"   = "enterpriseenrollment.manage.microsoft.com"
      "enterpriseregistration" = "enterpriseregistration.windows.net"
      "intercom._domainkey"    = "6aed7a36-c4bd-4ade-8393-6aea82b9456c.dkim.intercom.io"
      "lyncdiscover"           = "webdir.online.lync.com"
      "msoid"                  = "clientconfig.microsoftonline-p.net"
      "sip"                    = "sipdir.online.lync.com"
    }
    mx_records = {
      "info" = [
        {
          preference = 10,
          exchange   = "mxb.mailgun.org",
        },
        {
          preference = 10,
          exchange   = "mxa.mailgun.org",
        }
      ]
      "monitor" = [
        {
          preference = 20,
          exchange   = "mx2.int.mygravity.co",
        },
        {
          preference = 20,
          exchange   = "mx1.int.mygravity.co",
        }
      ]
      "@" = [
        {
          preference = 0,
          exchange   = "mygravity-co.mail.protection.outlook.com",
        }
      ]
      "rt" = [
        {
          preference = 10,
          exchange   = "mx1.int.mygravity.co",
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
        "v=spf1 ip4:93.174.64.0/21 include:_spf.google.com include:mail.zendesk.com include:spf.protection.outlook.com include:musvc.com include:spf.mandrillapp.com include:mailgun.org ~all",
        "MS=ms76064389",
        "google-site-verification=CRwV6HYsuMEOHIOiAcw4D1SMPCkdV8HKtkRFzh8BV2w"
      ]
      "info"                = ["v=spf1 include:mailgun.org ~all"]
      "mandrill._domainkey" = ["v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrLHiExVd55zd/IQ/J/mRwSRMAocV/hMB3jXwaHH36d9NaVynQFYV8NaWi69c1veUtRzGt7yAioXqLj7Z4TeEUoOLgrKsn8YnckGs9i3B3tVFB+Ch/4mPhXWiNfNdynHWBcPcbJ8kjEQ2U8y78dHZj1YeRXXVvWob2OaKynO8/lQIDAQAB;"]
      "mx._domainkey.info"  = ["k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2/cmjCcuiQx6SW56b+V//UDZ+O767Yp8lPFxhlfcw2iPTUpU8u671Ifg9zj70wgPXycfnQVn8PRlDF2ZcaITJR6YDk40r1PEZI9DX61tv/yhA4q7h/Ulfx4tB/WQAfa/8YhKu7f/TimNuTbjgW2sv8/A2WYJTvpeep8acgYlrtQIDAQAB"]

    }
  }
}

resource "azurerm_dns_cname_record" "mygravity_co_cname" {
  for_each = local.mygravity_co.cname_records

  name                = each.key
  zone_name           = azurerm_dns_zone.mygravity_co.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record              = each.value
}

resource "azurerm_dns_mx_record" "mygravity_co_mx" {
  for_each = local.mygravity_co.mx_records

  name                = each.key
  zone_name           = azurerm_dns_zone.mygravity_co.name
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

resource "azurerm_dns_srv_record" "mygravity_co_srv" {
  for_each = local.mygravity_co.srv_records

  name                = each.key
  zone_name           = azurerm_dns_zone.mygravity_co.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  record {
    priority = each.value["priority"]
    weight   = each.value["weight"]
    port     = each.value["port"]
    target   = each.value["target"]
  }
}

resource "azurerm_dns_txt_record" "mygravity_co_txt" {
  for_each = local.mygravity_co.txt_records

  name                = each.key
  zone_name           = azurerm_dns_zone.mygravity_co.name
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
