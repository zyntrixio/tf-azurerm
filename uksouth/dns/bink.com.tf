resource "azurerm_dns_zone" "bink-com" {
    name = "bink.com"
    resource_group_name = azurerm_resource_group.rg.name
}

# Current issues:
# Zone Apex is supposed to cname to "binkdev.wpengine.com"
# In cloudflare this is performed via cname flattening
# It doesn't look like we can do this with Azure DNS
# Created an A Record below, hopefully it doesn't change.

locals {
    bink_com = {
        a_records = {
            # Apex
            "@" = "35.230.130.143",

            # South Africa
            "api.za" = "127.0.0.1",
            "api.dev.za" = "127.0.0.1"
            "api.staging.za" = "127.0.0.1",

            # United States
            "api.us" = "127.0.0.1",
            "api.dev.us" = "127.0.0.1",
            "api.staging.us" = "127.0.0.1",

            # Bink Offices
            "ascot" = "194.74.152.11",  # |
            # | Duplicates
            "hq" = "194.74.152.11",     # |

            # SFTP
            "sftpcluster" = "40.115.33.68",
            "sftp" = "178.238.141.18",
            "sftp.gb" = "51.132.44.255",
            "sftp.staging.gb" = "51.132.44.241",

            # Random
            "rep1" = "178.238.141.23", # can go away after we turn off UKFast
            "chef" = "13.95.9.172", # not convinced we're using this, this might be the OG Amazon AWS instance
            "controller" = "137.117.246.94", # no idea what this is
            "docs" = "104.40.220.129", # can probably go away,
            "filewave" = "51.136.16.203",
            "git" = "51.132.44.248",
        }
        cname_records = {

            # API/Front Door
            "policies" = "bink-frontdoor.azurefd.net",
            "policies.gb" = "bink-frontdoor.azurefd.net"
            "policies.staging.gb" = "bink-frontdoor.azurefd.net",
            "performance.sandbox.gb" = "bink-frontdoor.azurefd.net",
            "mcwallet.dev.gb" = "bink-frontdoor.azurefd.net",
            "api" = "bink-frontdoor.azurefd.net",
            "api.gb" = "bink-frontdoor.azurefd.net",
            "api.preprod.gb" = "bink-frontdoor.azurefd.net",
            "api.staging.gb" = "bink-frontdoor.azurefd.net",
            "api.dev.gb" = "bink-frontdoor.azurefd.net",
            "api.sandbox.gb" = "bink-frontdoor.azurefd.net",
            "oat.sandbox.gb" = "bink-frontdoor.azurefd.net",
            "kibana.gb" = "bink-frontdoor.azurefd.net",
            "starbug.gb" = "bink-frontdoor.azurefd.net",

            # Website
            "www" = "binkdev.wpengine.com",

            # Office 365
            "enterpriseregistration.teams" = "enterpriseregistration.windows.net",
            "enterpriseenrollment.teams" = "enterpriseenrollment.manage.microsoft.com",
            "autodiscover.teams" = "autodiscover.outlook.com",
            "autodiscover" = "autodiscover.outlook.com",
            "msoid" = "clientconfig.microsoftonline-p.net",
            "lyncdiscover" = "webdir.online.lync.com",
            "sip" = "sipdir.online.lync.com",
            "enterpriseregistration" = "enterpriseregistration.windows.net",
            "enterpriseenrollment" = "enterpriseenrollment.manage.microsoft.com",
            "sip.teams" = "sipdir.online.lync.com",
            "lyncdiscover.teams" = "webdir.online.lync.com",
            "msoid.teams" = "clientconfig.microsoftonline-p.net"

            # Zendesk
            "help" = "binkcx.zendesk.com",
            "zendesk1" = "mail1.zendesk.com",
            "zendesk2" = "mail2.zendesk.com",
            "zendesk3" = "mail3.zendesk.com",
            "zendesk4" = "mail4.zendesk.com",

            # Mailchimp
            "k1._domainkey" = "dkim.mcsv.net",
        }
        mx_records = {
            "@" = [
                {
                    preference = 0,
                    exchange = "bink-com.mail.protection.outlook.com",
                }
            ]
            "teams" = [
                {
                    preference = 0,
                    exchange = "teams-bink-com.mail.protection.outlook.com",
                }
            ]
            "uk" = [
                {
                    preference = 10,
                    exchange = "mxa.mailgun.org",
                },
                {
                    preference = 10,
                    exchange = "mxb.mailgun.org",
                }
            ]
        }
        srv_records = {
            "_sipfederationtls._tcp" = {
                priority = 100,
                weight = 1,
                port = 5061,
                target = "sipfed.online.lync.com",
            }
            "_sip._tls" = {
                priority = 100,
                weight = 1,
                port = 443,
                target = "sipdir.online.lync.com",
            }
            "_sipfederationtls._tcp.teams" = {
                priority = 100,
                weight = 1,
                port = 5061,
                target = "sipfed.online.lync.com",
            }
            "_sip._tls.teams" = {
                priority = 100,
                weight = 1,
                port = 443,
                target = "sipdir.online.lync.com",
            }
        }
        txt_records = {
            "@" = [
                "atlassian-domain-verification=mqUsdFedKn6vro+U8Cacg/cxjaFFF3CWSE5Jbww0PwYRNdDs5xfJlkiluMUKZrn4",
                "google-site-verification=TkTtMyGRzTV8pXap0aQo980_lNSfYa9E2__r1kI6Djo",
                "v=spf1 include:spf.protection.outlook.com include:mail.zendesk.com include:eu.mailgun.org ?all",
                "MS=ms26724008",
                "apple-domain-verification=jOvmiNhPlgoqmBOx",
                "google-site-verification=QmvtYLsc8CuTNEVdHm70WrVy5GzPJVDcwV9zxGwgelQ",
            ]
            "teams" = [
                "v=spf1 include:spf.protection.outlook.com -all",
            ]
            "mailo._domainkey" = [
                "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtVJBtQtVQp/vOwG2a+cr9Asv4NV1dWyFUbrrMpzfq4C0i4wmWLwCAyPIue2Mi9WLZ5ygeo6iD1yOQS21XmmfnafgYhOPQ2Fm6rF044MwSNQRT6WTyxEGQ6IUaKQ87/91i3o8NqkXVI94Z2DuyGeijrK/fare/CHIqYzDv5eyHi8UjdgKfnQwsI89QGYF3Ey12dF1YBixKvk/+cjYiZFsAZh2r4x3N6ccpKfiw8Gblk1S45ZPvUWo7b0DxTaWP617UCN7MXOCUl7ecji84m/pjfpgORX4yJKJIudYiBGwWpd4BGB68KUNdMAqgVBENcYuik3fna6nfiddTmJ+6UsgiQIDAQAB",
            ]
            "zendeskverification" = [
                "182c696aec4aa197",
            ]
            "k1._domainkey.uk" = [
                "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCvl1dCiO2l9IC+hLLwHCmdaTeU2rbj3OZxMJGf7TzWi1NJ/o55XAQ+4D8eeAAJQ2mWjBdV0UFAKB3b1+SeOBxowWKNxBHjkK9C0pTao6LkcGyhg1tBa6KUjKoNUThuQEE6ovkQPEVho5Ryt1c4KaR5XaFZ8aPFMyRiLH3SzQXMkwIDAQAB",
            ]
            "uk" = [
                "v=spf1 include:mailgun.org ~all",
            ]
        }
    }
}

resource "azurerm_dns_a_record" "bink_com_a" {
    for_each = local.bink_com.a_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-com.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = [each.value]
}

resource "azurerm_dns_cname_record" "bink_com_cname" {
    for_each = local.bink_com.cname_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-com.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    record = each.value
}

resource "azurerm_dns_mx_record" "bink_com_mx" {
    for_each = local.bink_com.mx_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-com.name
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

resource "azurerm_dns_srv_record" "bink_com_srv" {
    for_each = local.bink_com.srv_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-com.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300

    record {
        priority = each.value["priority"]
        weight = each.value["weight"]
        port = each.value["port"]
        target = each.value["target"]
    }
}

resource "azurerm_dns_txt_record" "bink_com_txt" {
    for_each = local.bink_com.txt_records

    name = each.key
    zone_name = azurerm_dns_zone.bink-com.name
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
