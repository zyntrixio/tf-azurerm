resource "azurerm_dns_zone" "bink-sh" {
    name = "bink.sh"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "uksouth-bink-sh" {
    name = "uksouth.bink.sh"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "sh-elasticsearch" {
    name = "elasticsearch"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["192.168.6.20"]
}

resource "azurerm_private_dns_a_record" "sh-gitlab" {
    name = "gitlab"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["192.168.10.4"]
}

resource "azurerm_private_dns_a_record" "sh-chef" {
    name = "chef"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["192.168.5.4"]
}

resource "azurerm_private_dns_a_record" "sh-sentry" {
    name = "sentry"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["192.168.2.5"]
}

resource "azurerm_private_dns_a_record" "sh-kibana" {
    name = "kibana"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["192.168.6.4"]
}

resource "azurerm_private_dns_a_record" "sh-tableau" {
    name = "tableau"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["192.168.7.4"]
}

resource "azurerm_private_dns_a_record" "sh-tools" {
    name = "tools"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.4.0.4"]
}

resource "azurerm_private_dns_a_record" "sh-tools-k8s" {
    name = "tools.k8s"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.4.64.4"]
}

resource "azurerm_private_dns_a_record" "sh-sandbox-k8s" {
    name = "sandbox.k8s"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.3.64.4"]
}

resource "azurerm_private_dns_a_record" "sh-dev-k8s" {
    name = "dev.k8s"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.2.64.4"]
}

resource "azurerm_private_dns_a_record" "sh-staging-k8s" {
    name = "staging.k8s"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.1.64.4"]
}

resource "azurerm_private_dns_a_record" "sh-prod-k8s" {
    name = "prod.k8s"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.0.64.4"]
}

resource "azurerm_private_dns_a_record" "sh-cluster-autodiscover" {
    name = "cluster-autodiscover"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.4.0.4"]
}

resource "azurerm_private_dns_a_record" "sh-aqua-gateway" {
    name = "aqua-gateway"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.4.0.4"]
}

resource "azurerm_private_dns_a_record" "sh-dev-sftp" {
    name = "sftp.dev"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["192.168.25.4"]
}
