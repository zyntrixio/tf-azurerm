resource "azurerm_firewall_application_rule_collection" "software" {
    name = "Software"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 100
    action = "Allow"

    rule {
        name = "Ubuntu"
        source_addresses = ["*"]
        target_fqdns = [
            "security.ubuntu.com",
            "azure.archive.ubuntu.com",
            "keyserver.ubuntu.com",
            "ppa.launchpad.net",
            "archive.ubuntu.com",
            "api.snapcraft.io",
            "*.cdn.snapcraftcontent.com",
            "changelogs.ubuntu.com",
        ]
        protocol {
            port = "80"
            type = "Http"
        }
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Debian"
        source_addresses = ["*"]
        target_fqdns = ["deb.debian.org"]
        protocol {
            port = "80"
            type = "Http"
        }
    }
    rule {
        name = "Falco"
        source_addresses = ["*"]
        target_fqdns = ["falcosecurity.github.io"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name =  "Datawarehouse"
        source_addresses = ["*"]
        target_fqdns = [ 
            "xb90214.eu-west-2.aws.snowflakecomputing.com",
            "ee39463.eu-west-2.aws.snowflakecomputing.com",
            "ci34413.eu-west-2.aws.snowflakecomputing.com",
            "hub.getdbt.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "GitHub"
        source_addresses = ["*"]
        target_fqdns = ["github.com", "*.s3.amazonaws.com", "*.github.com", "*.githubusercontent.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "AWS"
        source_addresses = ["*"]
        target_fqdns = ["*.amazonaws.com"]  # AWS ECR is nested deeply under amazonaws.com
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Kubernetes"
        source_addresses = ["*"]
        target_fqdns = [
            "storage.googleapis.com",
            "download.docker.com",
            "get.docker.com",
            "discovery.etcd.io",
            "sts.windows.net",
            "login.windows.net",
            "login.microsoftonline.com",
            "management.azure.com",
            "graph.microsoft.com",
            "pkg.cfssl.org",
            "ghcr.io",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Azure Monitor"
        source_addresses = ["*"]
        target_fqdns = [
            "global.handler.control.monitor.azure.com",
            "*.uksouth.prometheus.monitor.azure.com",
            "*.uksouth-1.metrics.ingest.monitor.azure.com",
        ]
        protocol {
            port = 443
            type = "Https"
        }
    }
    rule {
        name = "Container Registries"
        source_addresses = ["*"]
        target_fqdns = [
            "*.gcr.io",
            "gcr.io",
            "*.docker.io",
            "*.azurecr.io",
            "quay.io",
            "*.quay.io",
            "production.cloudflare.docker.com",
            "*.cloudfront.net",
            "*.blob.core.windows.net",
            "docker.elastic.co",
            "docker-auth.elastic.co",
            "mcr.microsoft.com",
            "*.data.mcr.microsoft.com",
            "*.cdn.mscr.io",
            "cr.l5d.io",
            "registry.k8s.io",
            "*.pkg.dev",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "python-pypi"
        source_addresses = ["*"]
        target_fqdns = [
            "pypi.python.org",
            "pypi.org",
            "files.pythonhosted.org",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Microsoft Teams"
        source_addresses = ["*"]
        target_fqdns = [
            "hellobink.webhook.office.com",
            "outlook.office.com",
            "login.botframework.com",
            "smba.trafficmanager.net",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Cloudflare"
        source_addresses = ["*"]
        target_fqdns = ["api.cloudflare.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "LetsEncrypt"
        source_addresses = ["*"]
        target_fqdns = ["*.api.letsencrypt.org"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Linkerd"
        source_addresses = ["*"]
        target_fqdns = [
            "versioncheck.linkerd.io",
            "helm.linkerd.io",
            "api.buoyant.cloud",
            "helm.buoyant.cloud",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Sentry"
        source_addresses = ["*"]
        target_fqdns = [
            "hellobink.atlassian.net",
            "*.sentry.io",
            "sentry.io",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Bookstack"
        source_addresses = ["*"]
        target_fqdns = ["graph.windows.net"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Atlassian"
        source_addresses = ["*"]
        target_fqdns = [
            "api.opsgenie.com",
            "api.statuspage.io",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Azure Endpoints"
        source_addresses = ["*"]
        # From https://docs.microsoft.com/en-us/azure/azure-monitor/platform/om-agents#network
        target_fqdns = [
            "*.ods.opinsights.azure.com",
            "*.oms.opinsights.azure.com",
            "*.blob.core.windows.net",
            "*.azure-automation.net",
            "*.vault.azure.net",
            "www.microsoft.com",  # For getting RSS feeds
            "api.loganalytics.io",
            "aka.ms",  # For AzCopy
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Healthchecks.io"
        source_addresses = ["*"]
        target_fqdns = [
            "hchk.io",
            "hc-ping.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Tableau"
        source_addresses = ["*"]
        target_fqdns = [
            "*.tableau.com",
            "*.tableausoftware.com",
            "*.mapbox.com",
            "tableau.internal.cloudapp.net",
            "licensing.tableau.com",
            "apt.postgresql.org",
            "www.postgresql.org",
            "nginx.org",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Grafana"
        source_addresses = ["*"]
        target_fqdns = [
            "packages.grafana.com",
            "grafana.github.io",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "ClamAV"
        source_addresses = ["*"]
        target_fqdns = ["*.clamav.net"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "IPRangeSites" # For getting ip ranges
        source_addresses = ["*"]
        target_fqdns = ["docs.spreedly.com", "www.microsoft.com", "download.microsoft.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Checkly"
        source_addresses = ["*"]
        target_fqdns = ["api.checklyhq.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Google Cloud HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "secretmanager.googleapis.com",
            "oauth2.googleapis.com"
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Grafana Cloud HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "prometheus-prod-01-eu-west-0.grafana.net",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Auth0"
        source_addresses = ["*"]
        target_fqdns = [
            "bink.eu.auth0.com",
            "auth.bink.com",
        ]
        protocol {
          port = "443"
          type = "Https"
        }
    }
}

resource "azurerm_firewall_application_rule_collection" "olympus" {
    name = "Olympus"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 200
    action = "Allow"

    rule {
        name = "Bink HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "api.gb.bink.com",
            "api.staging.gb.bink.com",
            "api.dev.gb.bink.com",
            "bpl.gb.bink.com",
            "bpl.staging.gb.bink.com",
            "bpl.dev.gb.bink.com",
            "portal.staging.gb.bink.com",
            "*.bink.sh",
            "bink.com"
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Mailgun and Mailjet"
        source_addresses = [ "*" ]
        target_fqdns = [
            "api.mailgun.net",
            "api.eu.mailgun.net",
            "status.mailgun.com",
            "api.mailjet.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Hermes"
        source_addresses = ["*"]
        target_fqdns = [
            "api.twitter.com",
            "graph.facebook.com",
            "appleid.apple.com",
            "bink.blob.core.windows.net",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Metis"
        source_addresses = ["*"]
        target_fqdns = [
            "ws.mastercard.com",
            "api.qa.americanexpress.com",
            "api.dev2s.americanexpress.com",
            "api.qa2s.americanexpress.com",
            "apigateway.americanexpress.com",
            "apigateway2s.americanexpress.com",
            "api.americanexpress.com",
            "core.spreedly.com",
            "status.spreedly.com",
            "api.visa.com",
            "*.api.visa.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Midas"
        source_addresses = ["*"]
        target_fqdns = [
            "wasabiuat.wasabiworld.co.uk",
            "account.theclub.macdonaldhotels.co.uk",
            "accounts.eurostar.com",
            "api.avios.com",
            "api.loyalty.marksandspencer.services",
            "api.bink.membership.coop.co.uk",
            "api.membership.coop.co.uk",
            "api.prod.eurostar.com",
            "api.services.qantasloyalty.com",
            "api.wyevalegardencentres.co.uk",
            "assistive.airasia.com",
            "auth.morrisons.com",
            "beta.addisonlee.com",
            "bookings.priorityguestrewards.com",
            "customergateway-uat.iceland.co.uk",
            "customergateway.iceland.co.uk",
            "cws.givex.com",
            "identity.membership.coop.co.uk",
            "login.microsoftonline.com",
            "loyalty.harveynichols.com",
            "*.harveynichols.com",
            "order.gbk.co.uk",
            "prd-east.webapi.enterprise.co.uk",
            "prd.b6prdeng.net",
            "purehmv.com",
            "rewards.api.mygravity.co",
            "rewards.heathrow.com",
            "secure.accorhotels.com",
            "secure.avis.co.uk",
            "secure.harrods.com",
            "secure.tesco.com",
            "ssl.omnihotels.com",
            "starrewardapps.valero.com",
            "www.avis.co.uk",
            "www.beefeatergrillrewardclub.co.uk",
            "www.bigbrandtreasure.com",
            "www.boostjuicebars.co.uk",
            "www.boots.com",
            "www.brewersfayrebonusclub.co.uk",
            "www.clubcarlson.com",
            "www.coffee1.co.uk",
            "www.debenhams.com",
            "www.delta.com",
            "www.discoveryloyalty.com",
            "www.esprit.co.uk",
            "www.flytap.com",
            "www.foyalty.co.uk",
            "www.harrods.com",
            "www.hertz.co.uk",
            "www.hollandandbarrett.com",
            "www.houseoffraser.co.uk",
            "www.hyatt.com",
            "www.loylap.com",
            "www.malaysiaairlines.com",
            "www.mandco.com",
            "www.marksandspencer.com",
            "www.maximiles.co.uk",
            "www.miles-and-more.com",
            "www.paperchase.com",
            "www.priorityguestrewards.com",
            "www.quidco.com",
            "www.showcasecinemas.co.uk",
            "www.singaporeair.com",
            "www.superdrug.com",
            "www.tastyrewards.co.uk",
            "www.thaiairways.com",
            "www.thebodyshop.com",
            "www.theperfumeshop.com",
            "www.tkmaxx.com",
            "www.uk.jal.co.jp",
            "www.virginatlantic.com",
            "www.waterstones.com",
            "www.wyevalegardencentres.co.uk",
            "www121.jal.co.jp",
            "www2.hm.com",
            "wwws-uk1.givex.com",
            "wwws-uk2.givex.com",
            "virtserver.swaggerhub.com",
            "sm-uk.azure-api.net",
            "statement.club-individual.co.uk",
            "www.foyalty.co.uk",
            "www.maximiles.co.uk",
            "london-capi.ecrebo.com",
            "london-capi-test.ecrebo.com",
            "atreemouat.itsucomms.com",
            "atreemo.itsucomms.com",
            "beta-api.pepperhq.com",
            "api.pepperhq.com",
        ]
        protocol {
            port = "80"
            type = "Http"
        }
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Harmonia"
        source_addresses = ["*"]
        target_fqdns = [
            "tools.wasabi.atreemo.co.uk",
            "wasabi.atreemo.co.uk",
            "uk-bink-transactions-dev.azurewebsites.net", # Squaremeal Dev
            "uk-bink-transactions.azurewebsites.net", # Squaremeal Prod
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Athena"
        source_addresses = ["*"]
        target_fqdns = [
            "api.appannie.com",
            "www.googleapis.com",
            "analyticsreporting.googleapis.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Carina"
        source_addresses = ["*"]
        target_fqdns = [
            "api.jigsaw360.com",
            "dev.jigsaw360.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Freshservice"
        source_addresses = ["*"]
        target_fqdns = [
            "bink.freshservice.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Midas The Works"
        source_addresses = ["*"]
        target_fqdns = [
            "dev-dataconnect.givex.com",
            "beta-dataconnect.givex.com",
            "dc-uk2.givex.com",
            "dc-uk1.givex.com",
        ]
        protocol {
            port = "50104"
            type = "Https"
        }
        protocol {
            port = "50099"
            type = "Https"
        }
    }
}

resource "azurerm_firewall_nat_rule_collection" "sftp" {
    name = "sftp"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 110
    action = "Dnat"

    rule {
        name = "ssh"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = [azurerm_public_ip.pips.15.ip_address]
        translated_address = var.sftp_ip_address
        translated_port = "22"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "tableau" {
    name = "tableau"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 130
    action = "Dnat"

    rule {
        name = "tableau_psql"
        source_addresses = var.secure_origins
        destination_ports = ["5432"]
        destination_addresses = [azurerm_public_ip.pips.12.ip_address]
        translated_address = "10.11.131.4"
        translated_port = "5432"
        protocols = ["TCP"]
    }
    rule {
        name = "airbyte_temp"
        source_addresses = var.secure_origins
        destination_ports = ["8000"]
        destination_addresses = [azurerm_public_ip.pips.12.ip_address]
        translated_address = "192.168.200.4"
        translated_port = "8000"
        protocols = ["TCP"]
    }
    rule {
        name = "prefect_temp"
        source_addresses = var.secure_origins
        destination_ports = ["4200"]
        destination_addresses = [azurerm_public_ip.pips.12.ip_address]
        translated_address = "192.168.200.5"
        translated_port = "4200"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "ntp" {
    name = "ntp"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 110
    action = "Allow"

    rule {
        name = "ntp"
        source_addresses = ["*"]
        destination_ports = ["123"]
        destination_addresses = ["*"]
        protocols = ["UDP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "sftp" {
    name = "sftp"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 120
    action = "Allow"

    rule {
        name = "secure_origins"
        source_addresses = var.secure_origins
        destination_ports = ["22"]
        destination_addresses = ["52.213.204.110/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "ecrebo"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = ["52.213.204.110/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "amex"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = ["148.173.107.23"]
        protocols = ["TCP"]
    }
    rule {
        name = "wasabi"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = ["185.113.19.116/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "mtf.files.mastercard.com"
        source_addresses = ["*"]
        destination_ports = ["16022"]
        destination_addresses = ["216.119.218.19/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "files.mastercard.com"
        source_addresses = ["*"]
        destination_ports = ["16022"]
        destination_addresses = ["216.119.219.66/32"]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "cloudflare" {
    name = "cloudflare"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 130
    action = "Allow"

    rule {
        name = "dns" # Workaround for Cert Manager bink.sh validation
        source_addresses = ["*"]
        destination_ports = ["53"]
        destination_addresses = ["1.1.1.1", "1.0.0.1"]
        protocols = ["TCP", "UDP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "github" {
    name = "github"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 150
    action = "Allow"
    # TODO: Start using destination_fqdns, requires DNS Proxy
    # DNS Proxy must be enabled in order to use DestinationFqdns in Network Rules

    rule {
        name = "all-to-github-ssh"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = [ # Via: https://api.github.com/meta
            "192.30.252.0/22",
            "185.199.108.0/22",
            "140.82.112.0/20",
            "143.55.64.0/20",
            "13.114.40.48/32",
            "52.192.72.89/32",
            "52.69.186.44/32",
            "15.164.81.167/32",
            "52.78.231.108/32",
            "13.234.176.102/32",
            "13.234.210.38/32",
            "13.229.188.59/32",
            "13.250.177.223/32",
            "52.74.223.119/32",
            "13.236.229.21/32",
            "13.237.44.5/32",
            "52.64.108.95/32",
            "18.228.52.138/32",
            "18.228.67.229/32",
            "18.231.5.6/32",
            "20.201.28.151/32",
            "20.205.243.166/32",
            "102.133.202.242/32",
            "18.181.13.223/32",
            "54.238.117.237/32",
            "54.168.17.15/32",
            "3.34.26.58/32",
            "13.125.114.27/32",
            "3.7.2.84/32",
            "3.6.106.81/32",
            "18.140.96.234/32",
            "18.141.90.153/32",
            "18.138.202.180/32",
            "52.63.152.235/32",
            "3.105.147.174/32",
            "3.106.158.203/32",
            "54.233.131.104/32",
            "18.231.104.233/32",
            "18.228.167.86/32",
            "20.201.28.152/32",
            "20.205.243.160/32",
            "102.133.202.246/32"
        ]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "smtp" {
    name = "smtp"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 160
    action = "Allow"

    rule {
        name = "smtp" # We should log a helpdesk ticket with Mailgun to lock this down
        source_addresses = ["*"]
        destination_ports = ["465", "587"]
        destination_addresses = ["*"]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "outbound_sftp" {
    name = "outbound_sftp"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 170
    action = "Allow"

    rule {
        name = "barclays"
        source_addresses = ["*"]
        destination_ports = ["10023"]
        destination_addresses = ["157.83.104.20", "167.203.3.33", "167.203.19.33"]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "prod_amqp" {
    name = "prod_amqp"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 210
    action = "Allow"

    rule {
        name = "amqp"
        source_addresses = var.production_cidrs
        destination_ports = ["5671", "15671"]
        destination_addresses = ["192.168.22.0/24"]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "grafana_prometheus" {
    name = "grafana_to_prometheus"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_firewall.firewall.resource_group_name
    priority = 310
    action = "Allow"

    rule {
        name = "production"
        source_addresses = [var.aks_cidrs.prod]
        destination_ports = ["9090"]
        destination_addresses = [
            cidrhost(cidrsubnet(var.aks_cidrs.staging, 1, 0), 32766),
            cidrhost(cidrsubnet(var.aks_cidrs.dev, 1, 0), 32766),
        ]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "tableau" {
    name = "tableau"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 400
    action = "Allow"

    rule {
        name = "smb"
        source_addresses = ["192.168.101.0/24"]
        destination_ports = ["445"]
        destination_addresses = ["*"]
        protocols = ["TCP"]
    }
}

# TODO: Rewrite this to only use the IP Ranges for UK South
resource "azurerm_firewall_network_rule_collection" "aks" {
    name = "aks"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 450
    action = "Allow"

    rule {
        name = "Azure Storage SMB"
        source_addresses = ["10.0.0.0/8"]
        destination_ports = ["445"]
        destination_addresses = ["*"]
        protocols = ["TCP"]
    }
}

# The below is allows AKS clusters to be bootstrapped before the explicit
# network rules are created. This is a non-ideal scenario, but it's livable.
# Access is restricted to a 10/8 to prevent non-clusters from using this.
resource "azurerm_firewall_application_rule_collection" "aks" {
    name = "AzureKubernetesService"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 500
    action = "Allow"
    rule {
        name = "Azure Kubernetes Service"
        source_addresses = ["10.0.0.0/8"]
        fqdn_tags = ["AzureKubernetesService"]
    }
}
