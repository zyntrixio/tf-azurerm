resource "azurerm_firewall_application_rule_collection" "software" {
  name                = "Software"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "Ubuntu"
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
    name             = "Debian"
    source_addresses = ["*"]
    target_fqdns     = ["deb.debian.org"]
    protocol {
      port = "80"
      type = "Http"
    }
  }
  rule {
    name             = "NextDNS"
    source_addresses = ["*"]
    target_fqdns = [
      "api.nextdns.io",
      "dns.nextdns.io",
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    # Via: https://tailscale.com/kb/1082
    name             = "Tailscale"
    source_addresses = ["*"]
    target_fqdns = [
      "tailscale.com",
      "*.tailscale.com",
      "*.tailscale.io",
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "CloudAmqp"
    source_addresses = ["*"]
    target_fqdns     = ["*.cloudamqp.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Traefik"
    source_addresses = ["*"]
    target_fqdns     = ["traefik.github.io"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Airbyte"
    source_addresses = ["*"]
    target_fqdns     = ["airbytehq.github.io"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule { // This rule is not used according to Azure Log Analytics
    name             = "Falco"
    source_addresses = ["*"]
    target_fqdns     = ["falcosecurity.github.io"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Datawarehouse"
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
    name             = "ocsp-domains"
    source_addresses = ["*"]
    target_fqdns = [
      "ocsp.r2m01.amazontrust.com",
      "ocsp.rootca1.amazontrust.com",
      "ocsp.rootg2.amazontrust.com",
      "o.ss2.us",
      "ocsp.digicert.com",
    ]
    protocol {
      port = "80"
      type = "Http"
    }
  }
  rule {
    name             = "GitHub"
    source_addresses = ["*"]
    target_fqdns     = ["github.com", "*.s3.amazonaws.com", "*.github.com", "*.githubusercontent.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "AWS"
    source_addresses = ["*"]
    target_fqdns     = ["*.amazonaws.com"] # AWS ECR is nested deeply under amazonaws.com
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Kubernetes"
    source_addresses = ["*"]
    target_fqdns = [
      "storage.googleapis.com", // Not used according to Azure Log Analytics
      "download.docker.com",
      "get.docker.com",            // Not used according to Azure Log Analytics
      "discovery.etcd.io",         // Not used according to Azure Log Analytics
      "sts.windows.net",           // Not used according to Azure Log Analytics
      "login.windows.net",         // Not used according to Azure Log Analytics
      "login.microsoftonline.com", // Not used according to Azure Log Analytics
      "management.azure.com",
      "graph.microsoft.com",
      "pkg.cfssl.org", // Not used according to Azure Log Analytics
      "ghcr.io",
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Azure Monitor"
    source_addresses = ["*"]
    target_fqdns = [
      "global.handler.control.monitor.azure.com",
      "*.uksouth.prometheus.monitor.azure.com", // Not used according to Azure Log Analytics
      "*.uksouth-1.metrics.ingest.monitor.azure.com",
    ]
    protocol {
      port = 443
      type = "Https"
    }
  }
  rule {
    name             = "Container Registries"
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
    name             = "python-pypi"
    source_addresses = ["*"]
    target_fqdns = [
      "pypi.python.org", // Not used according to Azure Log Analytics
      "pypi.org",
      "files.pythonhosted.org",
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Microsoft Teams"
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
  rule { // Not used according to Azure Log Analytics
    name             = "Cloudflare"
    source_addresses = ["*"]
    target_fqdns     = ["api.cloudflare.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "LetsEncrypt"
    source_addresses = ["*"]
    target_fqdns     = ["*.api.letsencrypt.org"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule { // Not used anymore
    name             = "Linkerd"
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
    name             = "Sentry"
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
  rule { // Not used according to Azure Log Analytics
    name             = "Bookstack"
    source_addresses = ["*"]
    target_fqdns     = ["graph.windows.net"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule { // Not used according to Azure Log Analytics
    name             = "Atlassian"
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
    name             = "Azure Endpoints"
    source_addresses = ["*"]
    # From https://docs.microsoft.com/en-us/azure/azure-monitor/platform/om-agents#network
    target_fqdns = [
      "*.ods.opinsights.azure.com",
      "*.oms.opinsights.azure.com",
      "*.blob.core.windows.net", // Not used according to Azure Log Analytics
      "*.azure-automation.net",  // Not used according to Azure Log Analytics
      "*.vault.azure.net",       // Not used according to Azure Log Analytics
      "www.microsoft.com",       # For getting RSS feeds
      "api.loganalytics.io",
      "aka.ms", // Not used according to Azure Log Analytics
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule { // Not used according to Azure Log Analytics
    name             = "Healthchecks.io"
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
    name             = "Tableau"
    source_addresses = ["*"]
    target_fqdns = [
      "*.tableau.com",
      "*.tableausoftware.com",
      "*.mapbox.com",                  // not used according to Azure Log Analytics
      "tableau.internal.cloudapp.net", // not used according to Azure Log Analytics
      "licensing.tableau.com",
      "apt.postgresql.org",
      "www.postgresql.org", // not used according to Azure Log Analytics
      "nginx.org",
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule { // Not used according to Azure Log Analytics
    name             = "Grafana"
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
  rule { // Not used according to Azure Log Analytics
    name             = "ClamAV"
    source_addresses = ["*"]
    target_fqdns     = ["*.clamav.net"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "IPRangeSites" # For getting ip ranges
    source_addresses = ["*"]
    target_fqdns     = ["docs.spreedly.com", "www.microsoft.com", "download.microsoft.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Checkly"
    source_addresses = ["*"]
    target_fqdns     = ["api.checklyhq.com", "ping.checklyhq.com", "agent.checklyhq.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule { // Not used according to Azure Log Analytics
    name             = "Google Cloud HTTPS"
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
  rule { // Not used according to Azure Log Analytics
    name             = "Grafana Cloud HTTPS"
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
    name             = "Auth0"
    source_addresses = ["*"]
    target_fqdns = [
      "bink.eu.auth0.com",
      "bink-prod.uk.auth0.com",
      "auth.bink.com",            // not used according to Azure Log Analytics
      "auth.nonprod.gb.bink.com", // not used according to Azure Log Analytics
      "auth.gb.bink.com",         // not used according to Azure Log Analytics
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "olympus" {
  name                = "Olympus"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 200
  action              = "Allow"

  rule { // not used according to Azure Log Analytics
    name             = "Bink HTTPS"
    source_addresses = ["*"]
    target_fqdns = [
      "api.gb.bink.com",
      "api.staging.gb.bink.com",
      "api.dev.gb.bink.com",
      "bpl.gb.bink.com",
      "bpl.staging.gb.bink.com",
      "bpl.dev.gb.bink.com",
      "portal.staging.gb.bink.com",
      "portal.gb.bink.com",
      "*.bink.sh",
      "bink.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Mailgun and Mailjet"
    source_addresses = ["*"]
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
  rule { // not used according to Azure Log Analytics
    name             = "Hermes"
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
    name             = "Metis"
    source_addresses = ["*"]
    target_fqdns = [
      "ws.mastercard.com",              // not used according to Azure Log Analytics
      "api.qa.americanexpress.com",     // not used according to Azure Log Analytics
      "api.dev2s.americanexpress.com",  // not used according to Azure Log Analytics
      "api.qa2s.americanexpress.com",   // not used according to Azure Log Analytics
      "apigateway.americanexpress.com", // not used according to Azure Log Analytics
      "apigateway2s.americanexpress.com",
      "api.americanexpress.com", // not used according to Azure Log Analytics
      "core.spreedly.com",
      "status.spreedly.com", // not used according to Azure Log Analytics
      "api.visa.com",
      "*.api.visa.com", // not used according to Azure Log Analytics
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name             = "Midas"
    source_addresses = ["*"]
    target_fqdns = [
      "wasabiuat.wasabiworld.co.uk",           // not used according to Azure Log Analytics
      "account.theclub.macdonaldhotels.co.uk", // not used according to Azure Log Analytics
      "accounts.eurostar.com",                 // not used according to Azure Log Analytics
      "api.avios.com",                         // not used according to Azure Log Analytics
      "api.loyalty.marksandspencer.services",  // not used according to Azure Log Analytics
      "api.bink.membership.coop.co.uk",        // not used according to Azure Log Analytics
      "api.membership.coop.co.uk",             // not used according to Azure Log Analytics
      "api.prod.eurostar.com",                 // not used according to Azure Log Analytics
      "api.services.qantasloyalty.com",        // not used according to Azure Log Analytics
      "api.wyevalegardencentres.co.uk",        // not used according to Azure Log Analytics
      "assistive.airasia.com",                 // not used according to Azure Log Analytics
      "auth.morrisons.com",                    // not used according to Azure Log Analytics
      "beta.addisonlee.com",                   // not used according to Azure Log Analytics
      "bookings.priorityguestrewards.com",     // not used according to Azure Log Analytics
      "customergateway-uat.iceland.co.uk",     // not used according to Azure Log Analytics
      "customergateway.iceland.co.uk",         // not used according to Azure Log Analytics
      "cws.givex.com",                         // not used according to Azure Log Analytics
      "identity.membership.coop.co.uk",        // not used according to Azure Log Analytics
      "login.microsoftonline.com",             // not used according to Azure Log Analytics
      "loyalty.harveynichols.com",             // not used according to Azure Log Analytics
      "*.harveynichols.com",                   // not used according to Azure Log Analytics
      "order.gbk.co.uk",                       // not used according to Azure Log Analytics
      "prd-east.webapi.enterprise.co.uk",      // not used according to Azure Log Analytics
      "prd.b6prdeng.net",                      // not used according to Azure Log Analytics
      "purehmv.com",                           // not used according to Azure Log Analytics
      "rewards.api.mygravity.co",              // not used according to Azure Log Analytics
      "rewards.heathrow.com",                  // not used according to Azure Log Analytics
      "secure.accorhotels.com",                // not used according to Azure Log Analytics
      "secure.avis.co.uk",                     // not used according to Azure Log Analytics
      "secure.harrods.com",                    // not used according to Azure Log Analytics
      "secure.tesco.com",                      // not used according to Azure Log Analytics
      "ssl.omnihotels.com",                    // not used according to Azure Log Analytics
      "starrewardapps.valero.com",             // not used according to Azure Log Analytics
      "www.avis.co.uk",                        // not used according to Azure Log Analytics
      "www.beefeatergrillrewardclub.co.uk",    // not used according to Azure Log Analytics
      "www.bigbrandtreasure.com",              // not used according to Azure Log Analytics
      "www.boostjuicebars.co.uk",              // not used according to Azure Log Analytics
      "www.boots.com",                         // not used according to Azure Log Analytics
      "www.brewersfayrebonusclub.co.uk",       // not used according to Azure Log Analytics
      "www.clubcarlson.com",                   // not used according to Azure Log Analytics
      "www.coffee1.co.uk",                     // not used according to Azure Log Analytics
      "www.debenhams.com",                     // not used according to Azure Log Analytics
      "www.delta.com",                         // not used according to Azure Log Analytics
      "www.discoveryloyalty.com",              // not used according to Azure Log Analytics
      "www.esprit.co.uk",                      // not used according to Azure Log Analytics
      "www.flytap.com",                        // not used according to Azure Log Analytics
      "www.foyalty.co.uk",                     // not used according to Azure Log Analytics
      "www.harrods.com",                       // not used according to Azure Log Analytics
      "www.hertz.co.uk",                       // not used according to Azure Log Analytics
      "www.hollandandbarrett.com",             // not used according to Azure Log Analytics
      "www.houseoffraser.co.uk",               // not used according to Azure Log Analytics
      "www.hyatt.com",                         // not used according to Azure Log Analytics
      "www.loylap.com",                        // not used according to Azure Log Analytics
      "www.malaysiaairlines.com",              // not used according to Azure Log Analytics
      "www.mandco.com",                        // not used according to Azure Log Analytics
      "www.marksandspencer.com",               // not used according to Azure Log Analytics
      "www.maximiles.co.uk",                   // not used according to Azure Log Analytics
      "www.miles-and-more.com",                // not used according to Azure Log Analytics
      "www.paperchase.com",                    // not used according to Azure Log Analytics
      "www.priorityguestrewards.com",          // not used according to Azure Log Analytics
      "www.quidco.com",                        // not used according to Azure Log Analytics
      "www.showcasecinemas.co.uk",             // not used according to Azure Log Analytics
      "www.singaporeair.com",                  // not used according to Azure Log Analytics
      "www.superdrug.com",                     // not used according to Azure Log Analytics
      "www.tastyrewards.co.uk",                // not used according to Azure Log Analytics
      "www.thaiairways.com",                   // not used according to Azure Log Analytics
      "www.thebodyshop.com",                   // not used according to Azure Log Analytics
      "www.theperfumeshop.com",                // not used according to Azure Log Analytics
      "www.tkmaxx.com",                        // not used according to Azure Log Analytics
      "www.uk.jal.co.jp",                      // not used according to Azure Log Analytics
      "www.virginatlantic.com",                // not used according to Azure Log Analytics
      "www.waterstones.com",                   // not used according to Azure Log Analytics
      "www.wyevalegardencentres.co.uk",        // not used according to Azure Log Analytics
      "www121.jal.co.jp",                      // not used according to Azure Log Analytics
      "www2.hm.com",                           // not used according to Azure Log Analytics
      "wwws-uk1.givex.com",                    // not used according to Azure Log Analytics
      "wwws-uk2.givex.com",                    // not used according to Azure Log Analytics
      "virtserver.swaggerhub.com",             // not used according to Azure Log Analytics
      "statement.club-individual.co.uk",       // not used according to Azure Log Analytics
      "www.foyalty.co.uk",                     // not used according to Azure Log Analytics
      "www.maximiles.co.uk",                   // not used according to Azure Log Analytics
      "london-capi.ecrebo.com",                // not used according to Azure Log Analytics
      "london-capi-test.ecrebo.com",           // not used according to Azure Log Analytics
      "sm-uk.azure-api.net",
      "atreemouat.itsucomms.com",
      "atreemo.itsucomms.com",
      "beta-api.pepperhq.com",
      "api.pepperhq.com",
      "demoapi.podifi.com",
      "api.podifi.com",
      "rhianna.atreemo.uk",
      "sandbox.punchh.com",
      "dashboard.punchh.com",
      "mobileapi.punchh.com",
      "dashboard-api.punchh.com",
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
    name             = "Harmonia"
    source_addresses = ["*"]
    target_fqdns = [
      "tools.wasabi.atreemo.co.uk", // not used according to Azure Log Analytics
      "wasabi.atreemo.co.uk",       // not used according to Azure Log Analytics
      "rihanna.atreemo.uk",         // defined elsewhere
      "binkwebhook.atreemo.uk",
      "uk-bink-transactions-dev.azurewebsites.net", # Squaremeal Dev
      "uk-bink-transactions.azurewebsites.net",     # Squaremeal Prod
      "pos.sandbox.uk.eagleeye.com",                # Slim Chicken Dev
      "portal.uk.eagleeye.com",                     # Slim Chicken Prod
      "pos.uk.eagleeye.com",                        # Slim Chicken Prod
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule { // not used according to Azure Log Analytics
    name             = "Athena"
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
    name             = "Carina"
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
    name             = "Freshservice"
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
    name             = "Midas The Works"
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
    protocol { // Not used according to Azure Log Analytics
      port = "50099"
      type = "Https"
    }
  }
}


resource "azurerm_firewall_network_rule_collection" "ntp" { // not used according to Azure Log Analytics
  name                = "ntp"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 110
  action              = "Allow"

  rule {
    name                  = "ntp"
    source_addresses      = ["*"]
    destination_ports     = ["123"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "sftp" {
  name                = "sftp"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 120
  action              = "Allow"

  rule {
    name                  = "amex"
    source_addresses      = ["*"]
    destination_ports     = ["22"]
    destination_addresses = ["148.173.107.23"]
    protocols             = ["TCP"]
  }
  rule {
    name                  = "mtf.files.mastercard.com"
    source_addresses      = ["*"]
    destination_ports     = ["16022"]
    destination_addresses = ["216.119.218.19/32"]
    protocols             = ["TCP"]
  }
  rule {
    name                  = "files.mastercard.com"
    source_addresses      = ["*"]
    destination_ports     = ["16022"]
    destination_addresses = ["216.119.219.66/32"]
    protocols             = ["TCP"]
  }
  rule {
    name                  = "partners.tgifridays.co.uk"
    source_addresses      = ["*"]
    destination_ports     = ["22"]
    destination_addresses = ["185.64.224.12"]
    protocols             = ["TCP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "cloudflare" {
  name                = "cloudflare"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 130
  action              = "Allow"

  rule {
    name                  = "dns" # Workaround for Cert Manager bink.sh validation
    source_addresses      = ["*"]
    destination_ports     = ["53"]
    destination_addresses = ["1.1.1.1", "1.0.0.1"]
    protocols             = ["TCP", "UDP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "github" {
  name                = "github"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 150
  action              = "Allow"
  # TODO: Start using destination_fqdns, requires DNS Proxy
  # DNS Proxy must be enabled in order to use DestinationFqdns in Network Rules

  rule {
    name              = "all-to-github-ssh"
    source_addresses  = ["*"]
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

resource "azurerm_firewall_network_rule_collection" "smtp" { // not used according to Azure Log Analytics
  name                = "smtp"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 160
  action              = "Allow"

  rule {
    name                  = "smtp"
    source_addresses      = ["*"]
    destination_ports     = ["465", "587"]
    destination_addresses = ["*"]
    protocols             = ["TCP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "tailscale" {
  # Via: https://tailscale.com/kb/1082
  name                = "tailscale"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 180
  action              = "Allow"

  rule {
    name                  = "Wireguard"
    source_addresses      = ["*"]
    destination_ports     = ["41641"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
  rule {
    name                  = "STUN"
    source_addresses      = ["*"]
    destination_ports     = ["3478"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "grafana_prometheus" { // Not used according to Azure Log Analytics
  name                = "grafana_to_prometheus"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_firewall.firewall.resource_group_name
  priority            = 310
  action              = "Allow"

  rule {
    name              = "production"
    source_addresses  = [var.aks_cidrs.prod]
    destination_ports = ["9090"]
    destination_addresses = [
      cidrhost(cidrsubnet(var.aks_cidrs.staging, 1, 0), 32766),
      cidrhost(cidrsubnet(var.aks_cidrs.dev, 1, 0), 32766),
    ]
    protocols = ["TCP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "tableau" { // Not used according to Azure Log Analytics
  name                = "tableau"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 400
  action              = "Allow"

  rule {
    name                  = "smb"
    source_addresses      = ["192.168.101.0/24"]
    destination_ports     = ["445"]
    destination_addresses = ["*"]
    protocols             = ["TCP"]
  }
}

# TODO: Rewrite this to only use the IP Ranges for UK South
resource "azurerm_firewall_network_rule_collection" "aks" { // Not used according to Azure Log Analytics
  name                = "aks"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 450
  action              = "Allow"

  rule {
    name                  = "Azure Storage SMB"
    source_addresses      = ["10.0.0.0/8"]
    destination_ports     = ["445"]
    destination_addresses = ["*"]
    protocols             = ["TCP"]
  }
}

# The below is allows AKS clusters to be bootstrapped before the explicit
# network rules are created. This is a non-ideal scenario, but it's livable.
# Access is restricted to a 10/8 to prevent non-clusters from using this.
resource "azurerm_firewall_application_rule_collection" "aks" { // Not used according to Azure Log Analytics
  name                = "AzureKubernetesService"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 500
  action              = "Allow"
  rule {
    name             = "Azure Kubernetes Service"
    source_addresses = ["10.0.0.0/8"]
    fqdn_tags        = ["AzureKubernetesService"]
  }
}
