resource "azurerm_firewall_application_rule_collection" "apt-repos" {
  name = "apt-repos"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 100
  action = "Allow"

  rule {
    name = "ubuntu"
    source_addresses = ["*"]
    target_fqdns = [
      "security.ubuntu.com",
      "azure.archive.ubuntu.com",
      "keyserver.ubuntu.com",
      "ppa.launchpad.net",
    ]
    protocol {
      port = "80"
      type = "Http"
    }
  }
  rule {
    name = "datadog"
    source_addresses = ["*"]
    target_fqdns = ["apt.datadoghq.com"]
    protocol {
      port = "80"
      type = "Http"
    }
  }
  rule {
    name = "wazuh-packages"
    source_addresses = ["*"]
    target_fqdns = ["packages.wazuh.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "midas" {
  name = "midas"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 300
  action = "Allow"

  rule {
    name = "https"
    source_addresses = ["*"]
    target_fqdns = [
      "customergateway.iceland.co.uk",
      "api.membership.coop.co.uk",
      "account.theclub.macdonaldhotels.co.uk",
      "accounts.eu1.gigya.com",
      "accounts.eurostar.com",
      "api.avios.com",
      "api.bink-dev.com",
      "api.loyalty.marksandspencer.services",
      "api.prod.eurostar.com",
      "api.services.qantasloyalty.com",
      "api.wyevalegardencentres.co.uk",
      "assistive.airasia.com",
      "auth.morrisons.com",
      "beta.addisonlee.com",
      "bookings.priorityguestrewards.com",
      "cdns.gigya.com",
      "customergateway-uat.iceland.co.uk",
      "cws.givex.com",
      "login.microsoftonline.com",
      "loyalty.harveynichols.com",
      "membership.coop.co.uk",
      "order.gbk.co.uk",
      "prd-east.webapi.enterprise.co.uk",
      "prd.b6prdeng.net",
      "purehmv.com",
      "rewards.api.mygravity.co",
      "rewards.heathrow.com",
      "secure.accorhotels.com",
      "secure.avis.co.uk",
      "secure.harrods.com",
      "ssl.omnihotels.com",
      "starrewardapps.valero.com",
      "www.avis.co.uk",
      "www.beefeatergrillrewardclub.co.uk",
      "www.bigbrandtreasure.com",
      "www.boostjuicebars.co.uk",
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
      "www.nectar.com",
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
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "http"
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
}

resource "azurerm_firewall_application_rule_collection" "metis" {
  name = "metis"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 200
  action = "Allow"

  rule {
    name = "Mastercard"
    source_addresses = ["*"]
    target_fqdns = [
      "ws.mastercard.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "Amex"
    source_addresses = ["*"]
    target_fqdns = [
      "api.qa.americanexpress.com",
      "apigateway.americanexpress.com",
      "api.americanexpress.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "Visa"
    source_addresses = ["*"]
    target_fqdns = [
      ""
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "Spreedly"
    source_addresses = ["*"]
    target_fqdns = [
      "core.spreedly.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "azure" {
  name = "azure-resources"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 400
  action = "Allow"

  rule {
    name = "Bink Blob Storage"
    source_addresses = ["*"]
    target_fqdns = ["bink.blob.core.windows.net"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "Aphrodite Blob Storage"
    source_addresses = ["*"]
    target_fqdns = ["aphrodite.blob.core.windows.net"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "third-party-software" {
  name = "third-party-software"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 500
  action = "Allow"

  rule {
    name = "Hashicorp"
    source_addresses = [
      "192.168.1.0/25",
    ]
    target_fqdns = [
      "releases.hashicorp.com",
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "GitHub"
    source_addresses = ["*"]
    target_fqdns = [
      "github.com",
      "*.s3.amazonaws.com",
    ]
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
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "chef"
    source_addresses = ["*"]
    target_fqdns = [
      "packages.chef.io",
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
    name = "cfssl"
    source_addresses = ["*"]
    target_fqdns = [
      "pkg.cfssl.org",
      ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "container_registries"
    source_addresses = ["*"]
    target_fqdns = [
      "*.gcr.io",
      "gcr.io",
      "*.docker.io",
      "*.azurecr.io",
      "quay.io",
      "production.cloudflare.docker.com",
      "*.cloudfront.net",
      "*.blob.core.windows.net",
      ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "intercom"
    source_addresses = ["*"]
    target_fqdns = ["api.intercom.io"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "datadog"
    source_addresses = ["*"]
    target_fqdns = [
      "trace.agent.datadoghq.com",
      "process.datadoghq.com",
      "agent-intake.logs.datadoghq.com",
      "app.datadoghq.com",
      "*.agent.datadoghq.com",
    ]
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
    name = "cloudflare"
    source_addresses = ["*"]
    target_fqdns = ["api.cloudflare.com"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "letsencrypt"
    source_addresses = ["*"]
    target_fqdns = ["*.api.letsencrypt.org"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "wazuh-stega"
    source_addresses = ["*"]
    target_fqdns = ["800sky.stega.uk.net"]
    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "flux"
    source_addresses = ["*"]
    target_fqdns = ["checkpoint-api.weave.works"]
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
    name = "Slack"
    source_addresses = ["*"]
    target_fqdns = [
      "slack.com",
      "*.slack.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_nat_rule_collection" "ingress" {
  name = "ingress"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 100
  action = "Dnat"

  rule {
    name = "ssh"
    source_addresses = ["*"]
    destination_ports = ["22"]
    destination_addresses = ["${azurerm_public_ip.pip.0.ip_address}"]
    translated_address = "192.168.4.4"
    translated_port = "22"
    protocols = ["TCP"]
  }
  rule {
    name = "http"
    source_addresses = ["*"]
    destination_ports = ["80"]
    destination_addresses = ["${azurerm_public_ip.pip.0.ip_address}"]
    translated_address = "10.0.0.4"
    translated_port = "80"
    protocols = ["TCP"]
  }
  rule {
    name = "https"
    source_addresses = ["*"]
    destination_ports = ["443"]
    destination_addresses = ["${azurerm_public_ip.pip.0.ip_address}"]
    translated_address = "10.0.0.4"
    translated_port = "443"
    protocols = ["TCP"]
  }
  rule {
    name = "chef"
    source_addresses = ["*"]
    destination_ports = ["4444"]
    destination_addresses = ["${azurerm_public_ip.pip.0.ip_address}"]
    translated_address = "192.168.5.4"
    translated_port = "4444"
    protocols = ["TCP"]
  }
  rule {
    name = "kube-api"
    source_addresses = [
      "194.74.152.11/32",
      "80.229.2.38/32"
    ]
    destination_ports = ["6443"]
    destination_addresses = ["${azurerm_public_ip.pip.0.ip_address}"]
    translated_address = "10.0.64.4"
    translated_port = "6443"
    protocols = ["TCP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "ssh" {
  name                = "bastion-to-hosts"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority            = 100
  action              = "Allow"

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
    name = "all-to-freeradius"
    source_addresses = ["*"]
    destination_ports = ["1812"]
    destination_addresses = ["192.168.4.0/24"]
    protocols = ["UDP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "third-party-software" {
  name                = "third-party-software"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority            = 130
  action              = "Allow"

  rule {
    name = "siagent"
    source_addresses = ["*"]
    destination_ports = ["8999"]
    destination_addresses = ["40.81.125.193/32"]
    protocols = ["TCP"]
  }
  rule {
    name = "datadog logs"
    source_addresses = ["*"]
    destination_ports = ["10516"]
    destination_addresses = ["*"]
    protocols = ["TCP"]
  }
  rule {
    name = "stega ossec"
    source_addresses = ["*"]
    destination_ports = ["1515"]
    destination_addresses = ["51.143.173.121/32"]
    protocols = ["TCP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "gitlab" {
  name                = "gitlab"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority            = 120
  action              = "Allow"

  rule {
    name = "gitlab"
    source_addresses = ["*"]
    destination_ports = ["22"]
    destination_addresses = ["13.69.125.130/32"]
    protocols = ["TCP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "time" {
  name                = "time"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority            = 110
  action              = "Allow"

  rule {
    name = "ntp"
    source_addresses = ["*"]
    destination_ports = ["123"]
    destination_addresses = ["*"]
    protocols = ["UDP"]
  }
}
