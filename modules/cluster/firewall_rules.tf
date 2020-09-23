resource "azurerm_firewall_nat_rule_collection" "ingress" {
    provider = azurerm.core

    name = "ingress-${azurerm_resource_group.rg.name}"
    azure_firewall_name = var.firewall.firewall_name
    resource_group_name = var.firewall.resource_group_name
    priority = var.firewall.ingress_priority
    action = "Dnat"

    rule {
        name = "http"
        source_addresses = [var.firewall.ingress_source]
        destination_ports = [var.firewall.ingress_http]
        destination_addresses = [var.firewall.public_ip]
        translated_address = cidrhost(azurerm_subnet.worker.address_prefixes[0], 4)
        translated_port = "30000"
        protocols = ["TCP"]
    }
    rule {
        name = "https"
        source_addresses = [var.firewall.ingress_source]
        destination_ports = [var.firewall.ingress_https]
        destination_addresses = [var.firewall.public_ip]
        translated_address = cidrhost(azurerm_subnet.worker.address_prefixes[0], 4)
        translated_port = "30001"
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

# Shouldn't really be called egress
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

    dynamic "rule" {
        for_each = var.additional_firewall_rules
        content {
            name = rule.value["name"]
            source_addresses = rule.value["source_addresses"]
            destination_ports = rule.value["destination_ports"]
            destination_addresses = rule.value["destination_addresses"]
            protocols = rule.value["protocols"]
        }
    }
}
