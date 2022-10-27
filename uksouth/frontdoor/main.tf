resource "azurerm_resource_group" "rg" {
    name = "frontdoor"
    location = "uksouth"

    tags = var.tags
}

resource "azurerm_key_vault" "frontdoor" {
    name = "bink-frontdoor"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    sku_name = "standard"

    tags = var.tags

    access_policy {
        tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
        object_id = "f0222751-c786-45ca-bbfb-66037b63c4ac" # Azure FrontDoor

        secret_permissions = [
            "Get",
        ]

        certificate_permissions = [
            "Get",
        ]
    }

    access_policy {
        tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
        object_id = "aac28b59-8ac3-4443-bccc-3fb820165a08"  # DevOps

        secret_permissions = [
            "Backup",
            "Delete",
            "Get",
            "List",
            "Purge",
            "Recover",
            "Restore",
            "Set",
        ]

        certificate_permissions = [
            "Get",
            "List",
            "Update",
            "Create",
            "Import",
            "Delete",
            "Recover",
            "Backup",
            "Restore",
        ]
    }

}

resource "azurerm_frontdoor" "frontdoor" {
    name = "bink-frontdoor"
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

    frontend_endpoint {
        name = "default"
        host_name = "bink-frontdoor.azurefd.net"
    }

    backend_pool_load_balancing {
        name = "standard"
        additional_latency_milliseconds = 50
    }

    backend_pool_settings {
        enforce_backend_pools_certificate_name_check = true
        backend_pools_send_receive_timeout_seconds = 30
    }

    backend_pool_health_probe {
        name = "healthz"
        path = "/healthz"
        protocol = "Https"
        interval_in_seconds = 120
    }

    frontend_endpoint {
        name = "api-gb-bink-com"
        host_name = "api.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "uksouth-prod-api"

        backend {
            host_header = "api.prod0.uksouth.bink.sh"
            address = "api.prod0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        backend {
            host_header = "api.prod1.uksouth.bink.sh"
            address = "api.prod1.uksouth.bink.sh"
            http_port = 8001
            https_port = 4001
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-prod-api"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-api"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-prod-api-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    routing_rule {
        name = "uksouth-prod-content"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/content/*"]
        frontend_endpoints = ["api-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-api"
            cache_enabled = true
            cache_query_parameter_strip_directive = "StripNone"
        }
    }

    frontend_endpoint {
        name = "bpl-gb-bink-com"
        host_name = "bpl.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "uksouth-prod-bpl"

        backend {
            host_header = "bpl.prod0.uksouth.bink.sh"
            address = "bpl.prod0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        backend {
            host_header = "bpl.prod1.uksouth.bink.sh"
            address = "bpl.prod1.uksouth.bink.sh"
            http_port = 8001
            https_port = 4001
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-prod-bpl"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["bpl-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-bpl"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-prod-bpl-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["bpl-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    routing_rule {
        name = "uksouth-prod-bpl-content"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/content/*"]
        frontend_endpoints = ["bpl-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-bpl"
            cache_enabled = true
            cache_query_parameter_strip_directive = "StripNone"
        }
    }
    
    frontend_endpoint {
        name = "policies-gb-bink-com"
        host_name = "policies.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-prod-policies"

        backend {
            host_header = "policies.prod0.uksouth.bink.sh"
            address = "policies.prod0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        backend {
            host_header = "policies.prod1.uksouth.bink.sh"
            address = "policies.prod1.uksouth.bink.sh"
            http_port = 8001
            https_port = 4001
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-prod-policies"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["policies-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-policies"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-prod-policies-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["policies-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "lloyds-sit-sandbox-gb-bink-com"
        host_name = "lloyds-sit.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "lloyds-sit-reflector-sandbox-gb-bink-com"
        host_name = "lloyds-sit-reflector.sandbox.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-sandbox-docs"
        backend {
            host_header = "api2-docs.sandbox.uksouth.bink.sh"
            address = "api2-docs.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-docs"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["docs-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-docs"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-docs-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["docs-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "docs-sandbox-gb-bink-com"
        host_name = "docs.sandbox.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-sandbox-sit-lbg"
        backend {
            host_header = "lloyds-sit.sandbox.uksouth.bink.sh"
            address = "lloyds-sit.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-sit-lbg"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = [
            "lloyds-sit-sandbox-gb-bink-com",
        ]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-sit-lbg"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-sit-lbg-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["lloyds-sit-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-sandbox-lloyds-sit-reflector"
        backend {
            host_header = "lloyds-sit-reflector.sandbox.uksouth.bink.sh"
            address = "lloyds-sit-reflector.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-lloyds-sit-reflector"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["lloyds-sit-reflector-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-lloyds-sit-reflector"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-lloyds-sit-reflector-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["lloyds-sit-reflector-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "wallet-gb-bink-com"
        host_name = "wallet.gb.bink.com"
    }

    frontend_endpoint {
        name = "wasabi-gb-bink-com"
        host_name = "wasabi.gb.bink.com"
    }

    routing_rule {
        name = "binkweb-http-to-https"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = [
            "wallet-gb-bink-com",
            "wasabi-gb-bink-com",
        ]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }
}
resource "azurerm_frontdoor_custom_https_configuration" "custom_https_default" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["default"]
    custom_https_provisioning_enabled = false
}

resource "azurerm_frontdoor_custom_https_configuration" "api_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "policies_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["policies-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "bpl_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["bpl-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "docs_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["docs-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "lloyds_sit_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["lloyds-sit-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "wallet_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["wallet-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "wasabi_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["wasabi-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"

    }
}

resource "azurerm_frontdoor_custom_https_configuration" "lloyds_sit_reflector_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["lloyds-sit-reflector-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_monitor_diagnostic_setting" "diags" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_frontdoor.frontdoor.id
    log_analytics_workspace_id = var.loganalytics_id

    log {
        category = "FrontdoorAccessLog"
        enabled = true
        retention_policy {
            days = 0
            enabled = false
        }
    }
    log {
        category = "FrontdoorWebApplicationFirewallLog"
        enabled = true
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
}
