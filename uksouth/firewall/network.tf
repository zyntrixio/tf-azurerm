resource "azurerm_virtual_network" "vnet" {
    name = "firewall-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [var.ip_range]

    tags = var.tags
}

resource "azurerm_subnet" "subnet" {
    name = "AzureFirewallSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.ip_range]
}

resource "azurerm_public_ip_prefix" "prefix" {
    name = "firewall-pip-prefix"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    prefix_length = 28
    zones = [ "1", "2", "3" ]

    tags = var.tags
}

resource "azurerm_public_ip" "pips" {
    count = 16
    name = format("firewall-pip-prefix-%02d", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
    sku = "Standard"
    idle_timeout_in_minutes = 5
    public_ip_prefix_id = azurerm_public_ip_prefix.prefix.id
    zones = [ "1", "2", "3" ]

    tags = var.tags
}

# TODO: Cleanup the below IP Config Blocks by using Terraform 0.12 Syntax
resource "azurerm_firewall" "firewall" {
    name = "firewall"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "AZFW_VNet"
    sku_tier = "Standard"

    ip_configuration {
        name = "ipconfig0"
        subnet_id = azurerm_subnet.subnet.id
        public_ip_address_id = azurerm_public_ip.pips.0.id
    }
    ip_configuration {
        name = "ipconfig1"
        public_ip_address_id = azurerm_public_ip.pips.1.id
    }
    ip_configuration {
        name = "ipconfig2"
        public_ip_address_id = azurerm_public_ip.pips.2.id
    }
    ip_configuration {
        name = "ipconfig3"
        public_ip_address_id = azurerm_public_ip.pips.3.id
    }
    ip_configuration {
        name = "ipconfig4"
        public_ip_address_id = azurerm_public_ip.pips.4.id
    }
    ip_configuration {
        name = "ipconfig5"
        public_ip_address_id = azurerm_public_ip.pips.5.id
    }
    ip_configuration {
        name = "ipconfig6"
        public_ip_address_id = azurerm_public_ip.pips.6.id
    }
    ip_configuration {
        name = "ipconfig7"
        public_ip_address_id = azurerm_public_ip.pips.7.id
    }
    ip_configuration {
        name = "ipconfig8"
        public_ip_address_id = azurerm_public_ip.pips.8.id
    }
    ip_configuration {
        name = "ipconfig9"
        public_ip_address_id = azurerm_public_ip.pips.9.id
    }
    ip_configuration {
        name = "ipconfig10"
        public_ip_address_id = azurerm_public_ip.pips.10.id
    }
    ip_configuration {
        name = "ipconfig11"
        public_ip_address_id = azurerm_public_ip.pips.11.id
    }
    ip_configuration {
        name = "ipconfig12"
        public_ip_address_id = azurerm_public_ip.pips.12.id
    }
    ip_configuration {
        name = "ipconfig13"
        public_ip_address_id = azurerm_public_ip.pips.13.id
    }
    ip_configuration {
        name = "ipconfig14"
        public_ip_address_id = azurerm_public_ip.pips.14.id
    }
    ip_configuration {
        name = "ipconfig15"
        public_ip_address_id = azurerm_public_ip.pips.15.id
    }

    tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "diags" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_firewall.firewall.id
    log_analytics_workspace_id = var.loganalytics_id
    log_analytics_destination_type = "AzureDiagnostics"

    log {
        category = "AzureFirewallApplicationRule"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AzureFirewallNetworkRule"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AzureFirewallDnsProxy"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
    metric {
        category = "AllMetrics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }

    # New Logs, Hurrah! Disabled due to Azure Bug
    # Support ticket: #2212060050000779
    log {
        category = "AZFWNetworkRule"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWApplicationRule"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWNatRule"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWThreatIntel"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWIdpsSignature"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWDnsQuery"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWFqdnResolveFailure"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWFatFlow"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWFlowTrace"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWApplicationRuleAggregation"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWNetworkRuleAggregation"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWNatRuleAggregation"
        enabled = false
        retention_policy {
            days = 90
            enabled = true
        }
    }
}

# Literally the opposite of the above Diagnostic settings,
# for support to use in troubleshooting our issue
resource "azurerm_monitor_diagnostic_setting" "preview" {
    name = "preview"
    target_resource_id = azurerm_firewall.firewall.id
    log_analytics_workspace_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-loganalytics/providers/Microsoft.OperationalInsights/workspaces/uksouth-loganalytics-temp"
    log_analytics_destination_type = "Dedicated"

    log {
        category = "AzureFirewallApplicationRule"
        enabled = false
        retention_policy {
            days = 90
            enabled = false
        }
    }
    log {
        category = "AzureFirewallNetworkRule"
        enabled = false
        retention_policy {
            days = 90
            enabled = false
        }
    }
    log {
        category = "AzureFirewallDnsProxy"
        enabled = false
        retention_policy {
            days = 90
            enabled = false
        }
    }
    metric {
        category = "AllMetrics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }

    log {
        category = "AZFWNetworkRule"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWApplicationRule"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWNatRule"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWThreatIntel"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWIdpsSignature"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWDnsQuery"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWFqdnResolveFailure"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWFatFlow"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWFlowTrace"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWApplicationRuleAggregation"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWNetworkRuleAggregation"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AZFWNatRuleAggregation"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
}
