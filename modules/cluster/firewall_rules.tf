resource "azurerm_firewall_nat_rule_collection" "ingress" {
    provider = azurerm.core

    name = "ingress-${azurerm_resource_group.rg.name}"
    azure_firewall_name = var.firewall.firewall_name
    resource_group_name = var.firewall.resource_group_name
    priority = var.firewall.ingress_priority
    action = "Dnat"

    rule {
        name = "http"
        source_addresses = ["*"]
        destination_ports = [var.firewall.ingress_http]
        destination_addresses = [var.firewall.public_ip]
        translated_address = cidrhost(azurerm_subnet.worker.address_prefixes[0], 4)
        translated_port = "80"
        protocols = ["TCP"]
    }
    rule {
        name = "https"
        source_addresses = ["*"]
        destination_ports = [var.firewall.ingress_https]
        destination_addresses = [var.firewall.public_ip]
        translated_address = cidrhost(azurerm_subnet.worker.address_prefixes[0], 4)
        translated_port = "443"
        protocols = ["TCP"]
    }
    rule {
        name = "controller"
        source_addresses = concat(var.firewall.secure_origins, var.firewall.developer_ips)
        destination_ports = [var.firewall.ingress_controller]
        destination_addresses = [var.firewall.public_ip]
        translated_address = cidrhost(azurerm_subnet.controller.address_prefixes[0], 4)
        translated_port = "6443"
        protocols = ["TCP"]
    }
}
resource "azurerm_firewall_network_rule_collection" "egress" {
    provider = azurerm.core

    name = "${var.cluster_name}-egress"
    azure_firewall_name = var.firewall.firewall_name
    resource_group_name = var.firewall.resource_group_name
    priority = var.firewall.ingress_priority
    action = "Allow"

    rule {
        name = "Azure Redis"
        source_addresses = [var.vnet_cidr]
        destination_ports = ["6379", "6380"]
        destination_addresses = ["*"]
        protocols = ["TCP"]
    }
}
