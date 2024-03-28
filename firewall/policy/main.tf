terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" }
    github  = { source = "integrations/github", version = "~> 6.2.1" }
  }
}

variable "common" {
  type = object({
    location = optional(string, "uksouth")
  })
}

data "github_ip_ranges" "i" {}

resource "azurerm_resource_group" "i" {
  name     = "${var.common.location}-firewall-policy"
  location = var.common.location
}

resource "azurerm_firewall_policy" "i" {
  name                = azurerm_resource_group.i.name
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  sku                 = "Basic"
}

resource "azurerm_firewall_policy_rule_collection_group" "infrastructure" {
  name               = "Infrastructure"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 100
  network_rule_collection {
    name     = "Cloudflare"
    action   = "Allow"
    priority = 1000
    rule {
      name                  = "DNS"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["1.1.1.1", "1.0.0.0"]
      destination_ports     = ["53"]
    }
  }
  application_rule_collection {
    name     = "Ubuntu"
    action   = "Allow"
    priority = 2000
    rule {
      name = "APT Repository"
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses  = ["*"]
      destination_fqdns = ["security.ubuntu.com", "azure.archive.ubuntu.com", "archive.ubuntu.com"]
    }
    rule {
      name = "Changelogs"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["changelogs.ubuntu.com"]
    }
    rule {
      name = "Snapcraft"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.snapcraft.io", "*.cdn.snapcraftcontent.com"]
    }
  }
  application_rule_collection {
    name     = "Debian"
    action   = "Allow"
    priority = 2010
    rule {
      name = "APT Repository"
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses  = ["*"]
      destination_fqdns = ["deb.debian.org"]
    }
  }
  application_rule_collection {
    name     = "Docker"
    action   = "Allow"
    priority = 2020
    rule {
      name = "Docker"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["download.docker.com", "get.docker.com"]
    }
  }
  application_rule_collection {
    name     = "NextDNS"
    action   = "Allow"
    priority = 2030
    rule {
      name = "NextDNS"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.nextdns.io", "dns.nextdns.io"]
    }
  }
  application_rule_collection {
    name     = "CloudAMQP"
    action   = "Allow"
    priority = 2050
    rule {
      name = "CloudAMQP"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.cloudamqp.com"]
    }
  }
  application_rule_collection {
    name     = "Traefik"
    action   = "Allow"
    priority = 2060
    rule {
      name = "GitHub"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["traefik.github.io"]
    }
  }
  application_rule_collection {
    name     = "Airbyte"
    action   = "Allow"
    priority = 2070
    rule {
      name = "GitHub"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["airbytehq.github.io"]
    }
  }
  application_rule_collection {
    name     = "Certificate Transparency"
    action   = "Allow"
    priority = 2080
    rule {
      name = "Amazon"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.amazontrust.com"]
    }
    rule {
      name = "Digicert"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["ocsp.digicert.com"]
    }
    rule {
      name = "Starfield Tech"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["o.ss2.us"]
    }
  }
  application_rule_collection {
    name     = "Microsoft Services"
    action   = "Allow"
    priority = 2090
    rule {
      name = "Microsoft Website"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["www.microsoft.com", "download.microsoft.com"]
    }
    rule {
      name = "Microsoft Graph"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["management.azure.com", "graph.microsoft.com"]
    }
    rule {
      name = "Azure Monitor"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses = ["*"]
      destination_fqdns = [
        "*.ingest.monitor.azure.com",
        "global.handler.control.monitor.azure.com",
        "*.ods.opinsights.azure.com",
        "*.oms.opinsights.azure.com",
        "api.loganalytics.io",
      ]
    }
    rule {
      name = "Microsoft Teams"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["hellobink.webhook.office.com"]
    }
  }
  application_rule_collection {
    name     = "Python Tooling"
    action   = "Allow"
    priority = 2100
    rule {
      name = "Python"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["pypi.org", "files.pythonhosted.org"]
    }
  }
  application_rule_collection {
    name     = "LetsEncrypt"
    action   = "Allow"
    priority = 2110
    rule {
      name = "LetsEncrypt"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.api.letsencrypt.org"]
    }
  }
  application_rule_collection {
    name     = "Sentry"
    action   = "Allow"
    priority = 2120
    rule {
      name = "Sentry"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["o503751.ingest.sentry.io"]
    }
  }
  application_rule_collection {
    name     = "Checkly"
    action   = "Allow"
    priority = 2130
    rule {
      name = "Checkly"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.checklyhq.com", "ping.checklyhq.com"]
    }
  }
  application_rule_collection {
    name     = "Auth0"
    action   = "Allow"
    priority = 2140
    rule {
      name = "Auth0"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["bink.eu.auth0.com", "bink-prod.uk.auth0.com"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "tailscale" {
  name               = "Tailscale"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 110
  network_rule_collection {
    name     = "Block RFC1918 Addresses"
    action   = "Deny"
    priority = 1000
    rule {
      name                  = "Wireguard RFC1918"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      destination_ports     = [41641]
    }
  }
  network_rule_collection {
    name     = "Network Rules"
    action   = "Allow"
    priority = 1010
    rule {
      name                  = "Wireguard"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_ports     = [3478, 41641]
      destination_addresses = ["*"]
    }
  }
  application_rule_collection {
    name     = "Application Rules"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Tailscale API"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.tailscale.com", "*.tailscale.io"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "github" {
  name               = "GitHub"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 200
  network_rule_collection {
    name     = "GitHub Network Rules"
    action   = "Allow"
    priority = 1000
    rule {
      name                  = "SSH"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = data.github_ip_ranges.i.git_ipv4
      destination_ports     = ["22"]
    }
  }
  application_rule_collection {
    name     = "GitHub Application Rules"
    action   = "Allow"
    priority = 2000
    rule {
      name = "GitHub.com"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["github.com", "codeload.github.com"]
    }
    rule {
      name = "GitHubUserContent.com"
      protocols {
        port = "443"
        type = "Https"
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.githubusercontent.com"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "datawarehouse" {
  name               = "DataWarehouse"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 300
  application_rule_collection {
    name     = "Snowflake"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Snowflake Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["xb90214.eu-west-2.aws.snowflakecomputing.com"]
    }
    rule {
      name = "Snowflake UAT"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["ee39463.eu-west-2.aws.snowflakecomputing.com"]
    }
    rule {
      name = "Snowflake Dev"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["ci34413.eu-west-2.aws.snowflakecomputing.com"]
    }
  }
  application_rule_collection {
    name     = "GetDBT"
    action   = "Allow"
    priority = 2010
    rule {
      name = "DBT"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["hub.getdbt.com"]
    }
  }
  application_rule_collection {
    name     = "Tableau"
    action   = "Allow"
    priority = 2020
    rule {
      name = "Telemetry"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["prod.telemetry.tableausoftware.com", "qa.telemetry.tableausoftware.com"]
    }
    rule {
      name = "License Server"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["atr.licensing.tableau.com"]
    }
    rule {
      name = "NGINX"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.nginx.org"]
    }
    rule {
      name = "Postgres APT"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["apt.postgresql.org"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "registries" {
  name               = "ContainerRegistries"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 400
  application_rule_collection {
    name     = "GitHub Container Registry"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Registry"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["ghcr.io"]
    }
  }
  application_rule_collection {
    name     = "Microsoft Container Registry"
    action   = "Allow"
    priority = 2010
    rule {
      name = "Registry"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["mcr.microsoft.com", "*.mcr.microsoft.com"]
    }
  }
  application_rule_collection {
    name     = "Docker Hub"
    action   = "Allow"
    priority = 2020
    rule {
      name = "Registry"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["registry-1.docker.io", "production.cloudflare.docker.com"]
    }
  }
  application_rule_collection {
    name     = "Quay.io"
    action   = "Allow"
    priority = 2030
    rule {
      name = "Registry"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["quay.io", "*.quay.io"]
    }
  }
  application_rule_collection {
    name     = "pkg.dev"
    action   = "Allow"
    priority = 2040
    rule {
      name = "Registry"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.pkg.dev"]
    }
  }
  application_rule_collection {
    name     = "Kubernetes Container Registry"
    action   = "Allow"
    priority = 2050
    rule {
      name = "Registry"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["registry.k8s.io"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "sinch" {
  name               = "Sinch"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 500
  application_rule_collection {
    name     = "Mailgun"
    action   = "Allow"
    priority = 2000
    rule {
      name = "API"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.eu.mailgun.net"]
    }
  }
  application_rule_collection {
    name     = "Mailjet"
    action   = "Allow"
    priority = 2010
    rule {
      name = "API"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.mailjet.com"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "payment_schemes" {
  name               = "PaymentSchemes"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 600
  network_rule_collection {
    name     = "SFTP"
    action   = "Allow"
    priority = 1000
    rule {
      name                  = "American Express"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_ports     = [22]
      destination_addresses = ["148.173.107.23"]
    }
    rule {
      name                  = "Mastercard - Production"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_ports     = [22]
      destination_addresses = ["216.119.219.66/32"]
    }
    rule {
      name                  = "Mastercard - Staging"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_ports     = [22]
      destination_addresses = ["216.119.218.19/32"]
    }
  }
  application_rule_collection {
    name     = "Visa"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Visa"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.visa.com"]
    }
  }
  application_rule_collection {
    name     = "Mastercard"
    action   = "Allow"
    priority = 2010
    rule {
      name = "Mastercard"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.mastercard.com"]
    }
  }
  application_rule_collection {
    name     = "American Express"
    action   = "Allow"
    priority = 2020
    rule {
      name = "American Express"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.americanexpress.com"]
    }
  }
  application_rule_collection {
    name     = "Spreedly"
    action   = "Allow"
    priority = 2030
    rule {
      name = "Spreedly"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["core.spreedly.com"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "loyalty_schemes" {
  name               = "LoyatySchemes"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 700
  network_rule_collection {
    name     = "TGIFridays SFTP"
    action   = "Allow"
    priority = 1000
    rule {
      name                  = "SFTP"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_ports     = [22]
      destination_addresses = ["185.64.224.12"]
    }
  }
  application_rule_collection {
    name     = "Itsu"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["itsucomms.com", "api.pepperhq.com"]
    }
    rule {
      name = "UAT"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["atreemouat.itsucomms.com", "beta-api.pepperhq.com"]
    }
  }
  application_rule_collection {
    name     = "Atreemo"
    action   = "Allow"
    priority = 2010
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["rhianna.atreemo.uk", "binkwebhook.atreemo.uk"]
    }
  }
  application_rule_collection {
    name     = "Slim Chickens"
    action   = "Allow"
    priority = 2020
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.podifi.com", "pos.uk.eagleeye.com", "portal.uk.eagleeye.com"]
    }
    rule {
      name = "Demo"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["demoapi.podifi.com", "pos.sandbox.uk.eagleeye.com"]
    }
  }
  application_rule_collection {
    name     = "Squaremeal"
    action   = "Allow"
    priority = 2030
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["sm-uk.azure-api.net", "uk-bink-transactions.azurewebsites.net"]
    }
    rule {
      name = "Dev"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["uk-bink-transactions-dev.azurewebsites.net"]
    }
  }
  application_rule_collection {
    name     = "TGIFridays"
    action   = "Allow"
    priority = 2040
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dashboard.punchh.com", "mobileapi.punchh.com", "dashboard-api.punchh.com"]
    }
    rule {
      name = "Sandbox"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["sandbox.punchh.com"]
    }
  }
  application_rule_collection {
    name     = "ASOS"
    action   = "Allow"
    priority = 2050
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.jigsaw360.com"]
    }
    rule {
      name = "Dev"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dev.jigsaw360.com"]
    }
  }
  application_rule_collection {
    name     = "The Works"
    action   = "Allow"
    priority = 2060
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 50104
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dc-uk1.givex.com", "dc-uk2.givex.com"]
    }
    rule {
      name = "Dev"
      protocols {
        type = "Https"
        port = 50104
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dev-dataconnect.givex.com", "beta-dataconnect.givex.com"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "freshservice" {
  name               = "FreshService"
  firewall_policy_id = azurerm_firewall_policy.i.id
  priority           = 800
  application_rule_collection {
    name     = "FreshService"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Bink"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["bink.freshservice.com"]
    }
  }
}
