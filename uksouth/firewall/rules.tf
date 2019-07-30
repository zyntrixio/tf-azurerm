resource "azurerm_firewall_application_rule_collection" "apt-repos" {
  name = "apt-repos"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 100
  action = "Allow"

  rule {
    name = "ubuntu"
    source_addresses = [
      "*"
    ]
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
}

resource "azurerm_firewall_application_rule_collection" "tools" {
  name = "tools-and-apis"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 110
  action = "Allow"

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
    name = "hashicorp"
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
    name = "github"
    source_addresses = [
      "192.168.1.0/25",
    ]
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
    name = "kubernetes"
    source_addresses = [
      "192.168.1.0/25",
    ]
    target_fqdns = [
      "storage.googleapis.com",
      "download.docker.com",
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
}

resource "azurerm_firewall_application_rule_collection" "stega" {
  name = "stega"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 120
  action = "Allow"
  
  rule {
    name = "wazuh-packages"
    source_addresses = ["*"]
    target_fqdns = ["packages.wazuh.com"]
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
}

resource "azurerm_firewall_network_rule_collection" "stega" {
  name                = "stega"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority            = 120
  action              = "Allow"

  rule {
    name = "siagent"
    source_addresses = ["*"]
    destination_ports = ["8999"]
    destination_addresses = ["40.81.125.193"]
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
