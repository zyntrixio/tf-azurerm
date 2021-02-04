resource "azurerm_private_dns_zone" "uksouth-bink-sh" {
    name = "uksouth.bink.sh"
    resource_group_name = azurerm_resource_group.rg.name
}

// Things talk to chef.uksouth.bink.sh internally, could remove this and hairpin through afw
resource "azurerm_private_dns_a_record" "sh-chef" {
    name = "chef"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["192.168.5.4"]
}

// Needed for aqua enforcers to do the needful
resource "azurerm_private_dns_a_record" "sh-aqua-gateway" {
    name = "aqua-gateway"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.4.0.4"]
}

// Possibly used by aqua
resource "azurerm_private_dns_a_record" "sh-aqua" {
    name = "aqua"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["10.5.0.4"]
}


// Fix gitlab-runner: pypi.tools.bink.sh -> tools0.uksouth.bink.sh
// prometheus creds -> tools
resource "azurerm_private_dns_a_record" "tools0" {
    name = "tools0"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["51.132.44.245"]
}

// Fix cluster autodiscover going to tools.uksouth.bink.sh
resource "azurerm_private_dns_a_record" "sh-tools" {
    name = "tools"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["51.132.44.245"]
}
resource "azurerm_private_dns_a_record" "sh-cluster-autodiscover" {
    name = "cluster-autodiscover"
    zone_name = azurerm_private_dns_zone.uksouth-bink-sh.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = ["51.132.44.245"]
}
