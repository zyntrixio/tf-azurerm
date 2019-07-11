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
    ]
    protocol {
      port = "80"
      type = "Http"
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
}

resource "azurerm_firewall_nat_rule_collection" "test" {
  name = "testcollection"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority = 100
  action = "Dnat"

  rule {
    name = "ssh"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "22",
    ]
    destination_addresses = [
      "${azurerm_public_ip.pip.ip_address}",
    ]
    translated_address = "10.0.66.4"
    translated_port = "22"
    protocols = [
      "TCP",
    ]
  }
}

resource "azurerm_firewall_network_rule_collection" "test" {
  name                = "testcollection"
  azure_firewall_name = "${azurerm_firewall.firewall.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  priority            = 100
  action              = "Allow"

  rule {
    name = "testrule"

    source_addresses = [
      "10.0.66.0/24",
    ]

    destination_ports = [
      "22",
    ]

    destination_addresses = [
      "192.168.1.0/25",
    ]

    protocols = [
      "TCP",
    ]
  }
}
