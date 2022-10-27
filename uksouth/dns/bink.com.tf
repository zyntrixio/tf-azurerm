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
            "git" = "51.132.44.248",
            "tableau.gb" = "51.132.44.252",
            "tableau.sandbox.gb" = "51.132.44.253",
            "help" = "138.68.154.237",
        }
        cname_records = {

            # API/Front Door
            "policies.gb" = "bink-frontdoor.azurefd.net",
            "api.gb" = "bink-frontdoor.azurefd.net",
            "bpl.gb" = "bink-frontdoor.azurefd.net",
            "lloyds-sit.sandbox.gb" = "bink-frontdoor.azurefd.net",
            "lloyds-sit-reflector.sandbox.gb" = "bink-frontdoor.azurefd.net",
            "kibana.gb" = "bink-frontdoor.azurefd.net",

            # Auth0
            "auth" = "bink-cd-x0ncx4gd7fxbncmx.edge.tenants.eu.auth0.com",

            # Statuspage
            "spg._domainkey" = "spg.domainkey.u12618875.wl126.sendgrid.net",
            "spg2._domainkey" = "spg2.domainkey.u12618875.wl126.sendgrid.net",
            "statuspage-notifications" = "u12618875.wl126.sendgrid.net",

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

            # e2e Office 365
            "autodiscover.e2e" = "autodiscover.outlook.com",

            # Zendesk
            "zendesk1" = "mail1.zendesk.com",
            "zendesk2" = "mail2.zendesk.com",
            "zendesk3" = "mail3.zendesk.com",
            "zendesk4" = "mail4.zendesk.com",

            # Mailchimp
            "k1._domainkey" = "dkim.mcsv.net",

            # Atlassian
            "s1._domainkey" = "s1._domainkey.atlassian.net",
            "s2._domainkey" = "s2._domainkey.atlassian.net",

            # Office 365
            "selector1._domainkey" = "selector1-bink-com._domainkey.hellobink.onmicrosoft.com",
            "selector2._domainkey" = "selector2-bink-com._domainkey.hellobink.onmicrosoft.com",

            # FreshService
            "fs._domainkey" = "wl210509s1.domainkey.freshemail.io"
            "fs2._domainkey" = "wl210509s2.domainkey.freshemail.io"
            "fs3._domainkey" = "wl210509s3.domainkey.freshemail.io"
            "fsdkim" = "spfmx3.domainkey.freshemail.io"
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
            "e2e" = [
                {
                    preference = 0,
                    exchange = "e2e-bink-com.mail.protection.outlook.com",
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
                "v=spf1 include:spf.protection.outlook.com include:mail.zendesk.com include:eu.mailgun.org include:_spf.atlassian.net include:stspg-customer.com include:spf.mailjet.com ~all",
                "MS=ms26724008",
                "apple-domain-verification=jOvmiNhPlgoqmBOx",
                "google-site-verification=QmvtYLsc8CuTNEVdHm70WrVy5GzPJVDcwV9zxGwgelQ",
                "status-page-domain-verification=2ymxl519fl8r",
            ]
            "teams" = [
                "v=spf1 include:spf.protection.outlook.com -all",
            ]
            "mailo._domainkey" = [
                "k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtVJBtQtVQp/vOwG2a+cr9Asv4NV1dWyFUbrrMpzfq4C0i4wmWLwCAyPIue2Mi9WLZ5ygeo6iD1yOQS21XmmfnafgYhOPQ2Fm6rF044MwSNQRT6WTyxEGQ6IUaKQ87/91i3o8NqkXVI94Z2DuyGeijrK/fare/CHIqYzDv5eyHi8UjdgKfnQwsI89QGYF3Ey12dF1YBixKvk/+cjYiZFsAZh2r4x3N6ccpKfiw8Gblk1S45ZPvUWo7b0DxTaWP617UCN7MXOCUl7ecji84m/pjfpgORX4yJKJIudYiBGwWpd4BGB68KUNdMAqgVBENcYuik3fna6nfiddTmJ+6UsgiQIDAQAB",
            ]
            "mailjet._domainkey" = [
                "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHHq1EChTzv5Gq4rCq+QAL2+yc6JIJkN8kuUwIu8Z7/opusovpYXy3GbJtgp1an2EVATTfVQp5VH7WmWSuIf2/47TOHB0LW+7kYkQoKma2ZJ91u0kP6Udydzofvy+dOdEDvtd8btszxFHU6hosze7l1BjGeb/1rgdr4J22E6BxIQIDAQAB"
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
            "e2e" = [
                "v=spf1 include:spf.protection.outlook.com -all",
            ]
            "_github-challenge-binkhq.bink.com" = [
                "515a6a7363"
            ]
            "mailjet._abb31074" = [
                "abb310741ee0e9aba4bf0cf7b06bb8c7"
            ]
        }
    }
}

resource "azurerm_dns_caa_record" "apex" {
    name = "@"
    zone_name = azurerm_dns_zone.bink-com.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300

    record {
        flags = 0
        tag = "issue"
        value = "letsencrypt.org"
    }

    record {
        flags = 0
        tag = "issue"
        value = "sectigo.com"
    }

    record {
        flags = 0
        tag = "iodef"
        value = "mailto:devops@bink.com"
    }
}

resource "azurerm_dns_caa_record" "www" {
    name = "www"
    zone_name = azurerm_dns_zone.bink-com.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300

    record {
        flags = 0
        tag = "issue"
        value = "letsencrypt.org"
    }

    record {
        flags = 0
        tag = "iodef"
        value = "mailto:devops@bink.com"
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
