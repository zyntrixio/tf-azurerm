resource "azurerm_firewall_application_rule_collection" "software" {
    name = "Software"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 150
    action = "Allow"

    rule {
        name = "Ubuntu APT Repos"
        source_addresses = ["*"]
        target_fqdns = [
            "security.ubuntu.com",
            "azure.archive.ubuntu.com",
            "keyserver.ubuntu.com",
            "ppa.launchpad.net",
            "archive.ubuntu.com",
        ]
        protocol {
            port = "80"
            type = "Http"
        }
    }
    rule {
        name = "Debian APT Repos"
        source_addresses = ["*"]
        target_fqdns = [
            "deb.debian.org",
            "security.debian.org",
        ]
        protocol {
            port = "80"
            type = "Http"
        }
    }
    rule {
        name = "Datadog HTTP"
        source_addresses = ["*"]
        target_fqdns = [
            "apt.datadoghq.com",
            "trace.agent.datadoghq.com",
            "process.datadoghq.com",
            "agent-intake.logs.datadoghq.com",
            "app.datadoghq.com",
            "*.agent.datadoghq.com",
        ]
        protocol {
            port = "80"
            type = "Http"
        }
    }
    rule {
        name = "Datadog HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "*.datadoghq.com"
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }

    rule {
        name = "Stega"
        source_addresses = ["*"]
        target_fqdns = ["packages.wazuh.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Hashicorp"
        source_addresses = ["192.168.1.0/25"]
        target_fqdns = ["releases.hashicorp.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "GitHub"
        source_addresses = ["*"]
        target_fqdns = ["github.com", "*.s3.amazonaws.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Gitlab"
        source_addresses = ["*"]
        target_fqdns = ["git.bink.com"]
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
            "discovery.etcd.io",
            "sts.windows.net",
            "login.windows.net",
            "login.microsoftonline.com",
            "management.azure.com",
            "pkg.cfssl.org",
        ]
        protocol {
            port = "443"
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
            "*.cdn.mscr.io",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Chef"
        source_addresses = ["*"]
        target_fqdns = [
            "packages.chef.io",
            "omnitruck.chef.io",
            "www.chef.io",
            "www.rubygems.org",
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
        name = "Intercom"
        source_addresses = ["*"]
        target_fqdns = ["api.intercom.io"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Slack"
        source_addresses = ["*"]
        target_fqdns = ["slack.com", "*.slack.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Microsoft Teams"
        source_addresses = ["*"]
        target_fqdns = ["outlook.office.com"]
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
        name = "Lets Encrypt"
        source_addresses = ["*"]
        target_fqdns = ["*.api.letsencrypt.org"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Flux CD"
        source_addresses = ["*"]
        target_fqdns = ["checkpoint-api.weave.works"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Linkerd"
        source_addresses = ["*"]
        target_fqdns = ["versioncheck.linkerd.io"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Sentry"
        source_addresses = ["*"]
        target_fqdns = ["sentry.bink.com"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "ifconfig.co"
        source_addresses = ["*"]
        target_fqdns = ["ifconfig.co"]
        protocol {
            port = "80"
            type = "Http"
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
        name = "xMatters"
        source_addresses = ["*"]
        target_fqdns = [
            "bink-np.xmatters.com",
            "bink.xmatters.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Elasticsearch"
        source_addresses = ["*"]
        target_fqdns = ["artifacts.elastic.co"]
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
            "*.vault.azure.net"
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Qualys"
        source_addresses = ["*"]
        target_fqdns = [
            "*.qualys.eu"
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
            "hchk.io"
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
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Grafana"
        source_addresses = ["*"]
        target_fqdns = ["packages.grafana.com"]
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
    priority = 250
    action = "Allow"

    rule {
        name = "Bink HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "api.bink.com",
            "api.gb.bink.com",
            "api.preprod.gb.bink.com",
            "api.staging.gb.bink.com",
            "api.dev.gb.bink.com",
            "api.sandbox.gb.bink.com",
            "*.bink-sandbox.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Hermes HTTPS"
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
        name = "Lethe HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "api.mailgun.net",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Metis HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "ws.mastercard.com",
            "api.qa.americanexpress.com",
            "apigateway.americanexpress.com",
            "api.americanexpress.com",
            "core.spreedly.com",
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Midas HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "wasabiuat.wasabiworld.co.uk",
            "account.theclub.macdonaldhotels.co.uk",
            "accounts.eurostar.com",
            "api.avios.com",
            "api.bink-dev.com",
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
        ]
        protocol {
            port = "443"
            type = "Https"
        }
    }
    rule {
        name = "Midas HTTP"
        source_addresses = ["*"]
        target_fqdns = [
            "statement.club-individual.co.uk",
            "www.foyalty.co.uk",
            "www.maximiles.co.uk"
        ]
        protocol {
            port = "80"
            type = "Http"
        }
    }
    rule {
        name = "Midas Ecrebo HTTPS"
        source_addresses = ["*"]
        target_fqdns = [
            "london-capi.ecrebo.com",
            "london-capi-test.ecrebo.com"
        ]
        protocol {
            port = "2361"
            type = "Https"
        }
    }
    rule {
        name = "Athena HTTPS"
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
        name = "Aphrodite HTTPS"
        source_addresses = ["*"]
        target_fqdns = ["aphrodite.blob.core.windows.net"]
        protocol {
            port = "443"
            type = "Https"
        }
    }
}

resource "azurerm_firewall_nat_rule_collection" "ingress" {
    name = "ingress"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 100
    action = "Dnat"

    rule {
        name = "prod_http"
        source_addresses = ["*"]
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.0.ip_address]
        translated_address = "10.0.0.4"
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "prod_https"
        source_addresses = ["*"]
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.0.ip_address]
        translated_address = "10.0.0.4"
        translated_port = "443"
        protocols = ["TCP"]
    }
    rule {
        name = "staging_http"
        source_addresses = ["*"]
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.1.ip_address]
        translated_address = "10.1.0.4"
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "staging_https"
        source_addresses = ["*"]
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.1.ip_address]
        translated_address = "10.1.0.4"
        translated_port = "443"
        protocols = ["TCP"]
    }
    rule {
        name = "dev_http"
        source_addresses = ["*"]
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.2.ip_address]
        translated_address = "10.2.0.4"
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "dev_https"
        source_addresses = ["*"]
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.2.ip_address]
        translated_address = "10.2.0.4"
        translated_port = "443"
        protocols = ["TCP"]
    }
    rule {
        name = "sandbox_http"
        source_addresses = ["*"]
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.3.ip_address]
        translated_address = "10.3.0.4"
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "sandbox_https"
        source_addresses = ["*"]
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.3.ip_address]
        translated_address = "10.3.0.4"
        translated_port = "443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "kube" {
    name = "kube"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 110
    action = "Dnat"
    rule {
        name = "prod_kube"
        source_addresses = var.secure_origins
        destination_ports = ["6443"]
        destination_addresses = [azurerm_public_ip.pips.0.ip_address]
        translated_address = "10.0.64.4"
        translated_port = "6443"
        protocols = ["TCP"]
    }
    rule {
        name = "staging_kube"
        source_addresses = var.secure_origins
        destination_ports = ["6443"]
        destination_addresses = [azurerm_public_ip.pips.1.ip_address]
        translated_address = "10.1.64.4"
        translated_port = "6443"
        protocols = ["TCP"]
    }
    rule {
        name = "dev_kube"
        source_addresses = var.secure_origins
        destination_ports = ["6443"]
        destination_addresses = [azurerm_public_ip.pips.2.ip_address]
        translated_address = "10.2.64.4"
        translated_port = "6443"
        protocols = ["TCP"]
    }
    rule {
        name = "sandbox_kube"
        source_addresses = var.secure_origins
        destination_ports = ["6443"]
        destination_addresses = [azurerm_public_ip.pips.3.ip_address]
        translated_address = "10.3.64.4"
        translated_port = "6443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "bastion" {
    name = "bastion"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 120
    action = "Dnat"

    rule {
        name = "ssh"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = [azurerm_public_ip.pips.0.ip_address]
        translated_address = var.bastion_ip_address
        translated_port = "22"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "chef" {
    name = "chef"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 130
    action = "Dnat"

    rule {
        name = "chef"
        source_addresses = ["*"]
        destination_ports = ["4444"]
        destination_addresses = [azurerm_public_ip.pips.0.ip_address]
        translated_address = "192.168.5.4"
        translated_port = "4444"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "kibana" {
    name = "kibana"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 140
    action = "Dnat"

    rule {
        name = "kibana_http"
        source_addresses = var.secure_origins
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.15.ip_address]
        translated_address = "192.168.6.4"
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "kibana_https"
        source_addresses = var.secure_origins
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.15.ip_address]
        translated_address = "192.168.6.4"
        translated_port = "443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "argus" {
    name = "argus"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 150
    action = "Dnat"

    rule {
        name = "argus_http"
        source_addresses = var.secure_origins
        destination_ports = ["8001"]
        destination_addresses = [azurerm_public_ip.pips.15.ip_address]
        translated_address = "192.168.6.84"
        translated_port = "8001"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "sftp" {
    name = "sftp"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 160
    action = "Dnat"

    rule {
        name = "prod_sftp"
        source_addresses = ["*"]
        destination_ports = ["2222"]
        destination_addresses = [azurerm_public_ip.pips.0.ip_address]
        translated_address = "10.0.0.4"
        translated_port = "2222"
        protocols = ["TCP"]
    }
    rule {
        name = "staging_sftp"
        source_addresses = ["*"]
        destination_ports = ["2222"]
        destination_addresses = [azurerm_public_ip.pips.1.ip_address]
        translated_address = "10.1.0.4"
        translated_port = "2222"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "sentry" {
    name = "sentry"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 170
    action = "Dnat"

    rule {
        name = "sentry_http"
        source_addresses = ["*"]
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.14.ip_address]
        translated_address = var.sentry_ip_address
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "sentry_https"
        source_addresses = ["*"]
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.14.ip_address]
        translated_address = var.sentry_ip_address
        translated_port = "443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "tableau" {
    name = "tableau"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 180
    action = "Dnat"

    rule {
        name = "tableau_http"
        source_addresses = ["*"]
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.13.ip_address]
        translated_address = var.tableau_ip_address
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "tableau_https"
        source_addresses = ["*"]
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.13.ip_address]
        translated_address = var.tableau_ip_address
        translated_port = "443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "alertmanager" {
    name = "alertmanager"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 190
    action = "Dnat"

    rule {
        name = "alertmanager_http"
        source_addresses = var.secure_origins
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.10.ip_address]
        translated_address = "192.168.6.52"
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "alertmanager_https"
        source_addresses = var.secure_origins
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.10.ip_address]
        translated_address = "192.168.6.52"
        translated_port = "443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "prometheus" {
    name = "prometheus"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 200
    action = "Dnat"

    rule {
        name = "prometheus_http"
        source_addresses = var.secure_origins
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.11.ip_address]
        translated_address = "192.168.6.68"
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "prometheus_https"
        source_addresses = var.secure_origins
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.11.ip_address]
        translated_address = "192.168.6.68"
        translated_port = "443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_nat_rule_collection" "grafana" {
    name = "grafana"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 210
    action = "Dnat"

    rule {
        name = "grafana_http"
        source_addresses = var.secure_origins
        destination_ports = ["80"]
        destination_addresses = [azurerm_public_ip.pips.12.ip_address]
        translated_address = "192.168.6.36"
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "grafana_https"
        source_addresses = var.secure_origins
        destination_ports = ["443"]
        destination_addresses = [azurerm_public_ip.pips.12.ip_address]
        translated_address = "192.168.6.36"
        translated_port = "443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "ssh" {
    name = "bastion-to-hosts"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 100
    action = "Allow"

    rule {
        name = "bastion-to-production"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["10.0.0.0/16"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-staging"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["10.1.0.0/16"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-dev"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["10.2.0.0/16"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-sandbox"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["10.3.0.0/16"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-vault"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["192.168.1.0/24"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-sentry"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["192.168.2.0/24"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-sftp"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["192.168.3.0/24"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-chef"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["192.168.5.0/24"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-monitoring"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["192.168.6.0/24"]
        protocols = ["TCP"]
    }
    rule {
        name = "bastion-to-tableau"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["192.168.7.0/24"]
        protocols = ["TCP"]
    }

    rule { // Temp
        name = "bastion-to-dev6502"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["6502"]
        destination_addresses = ["10.2.0.0/16"]
        protocols = ["TCP"]
    }

    rule {
        name = "bastion-to-tools"
        source_addresses = ["192.168.4.0/24"]
        destination_ports = ["22"]
        destination_addresses = ["10.4.0.0/16"]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "monitoring" {
    name = "Monitoring"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 110
    action = "Allow"

    rule {
        name = "all-to-elasticsearch"
        source_addresses = ["*"]
        destination_ports = ["9200"]
        destination_addresses = ["192.168.6.16/28"]
        protocols = ["TCP"]
    }
    rule {
        name = "production-to-kibana"
        source_addresses = ["10.0.0.0/18"]
        destination_ports = ["5601"]
        destination_addresses = ["192.168.6.0/28"]
        protocols = ["TCP"]
    }
    rule {
        name = "prometheus-to-node-exporter"
        source_addresses = ["192.168.6.64/28"]
        destination_ports = ["9100"]
        destination_addresses = ["*"]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "sentry" {
    name = "Sentry"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 120
    action = "Allow"

    rule {
        name = "production-to-sentry"
        source_addresses = ["10.0.0.0/16"]
        destination_ports = ["80", "443"]
        destination_addresses = ["${var.sentry_ip_address}/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "staging-to-sentry"
        source_addresses = ["10.1.0.0/16"]
        destination_ports = ["80", "443"]
        destination_addresses = ["${var.sentry_ip_address}/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "dev-to-sentry"
        source_addresses = ["10.2.0.0/16"]
        destination_ports = ["80", "443"]
        destination_addresses = ["${var.sentry_ip_address}/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "sandbox-to-sentry"
        source_addresses = ["10.3.0.0/16"]
        destination_ports = ["80", "443"]
        destination_addresses = ["${var.sentry_ip_address}/32"]
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "egress" {
    name = "Egress"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.rg.name
    priority = 150
    action = "Allow"

    rule {
        name = "Stega OSSEC Agent"
        source_addresses = ["*"]
        destination_ports = ["443", "1515"]
        destination_addresses = ["51.143.173.121/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "Stega Search Inform Agent"
        source_addresses = ["*"]
        destination_ports = ["8999"]
        destination_addresses = ["40.81.125.193/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "Datadog Logs"
        source_addresses = ["*"]
        destination_ports = ["10516"]
        destination_addresses = ["*"]
        protocols = ["TCP"]
    }
    rule {
        name = "GitLab SSH"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = ["13.69.125.130/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "NTP Time Sync"
        source_addresses = ["*"]
        destination_ports = ["123"]
        destination_addresses = ["*"]
        protocols = ["UDP"]
    }
    rule {
        name = "Ecrebo SFTP"
        source_addresses = ["*"]
        destination_ports = ["22"]
        destination_addresses = ["52.213.204.110/32"]
        protocols = ["TCP"]
    }
    rule {
        name = "Azure Redis"
        source_addresses = ["10.0.0.0/18", "10.1.0.0/18", "10.2.0.0/18", "10.3.0.0/18"]
        destination_ports = ["6379", "6380"]
        destination_addresses = ["*"]
        protocols = ["TCP"]
    }
    rule {
        name = "CloudFlare DNS" # Workaround for Cert Manager bink.sh validation
        source_addresses = ["*"]
        destination_ports = ["53"]
        destination_addresses = ["1.1.1.1", "1.0.0.1"]
        protocols = ["TCP"]
    }
    rule {
        name = "Folding-at-Home Proxy"
        source_addresses = ["*"]
        destination_ports = ["8000"]
        destination_addresses = ["167.172.50.165"]
        protocols = ["TCP"]
    }
}
