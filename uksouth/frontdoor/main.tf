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
            "get",
        ]

        certificate_permissions = [
            "get",
        ]
    }

    access_policy {
        tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
        object_id = "aac28b59-8ac3-4443-bccc-3fb820165a08"  # DevOps

        secret_permissions = [
            "backup",
            "delete",
            "get",
            "list",
            "purge",
            "recover",
            "restore",
            "set",
        ]

        certificate_permissions = [
            "get",
            "list",
            "update",
            "create",
            "import",
            "delete",
            "recover",
            "backup",
            "restore",
        ]
    }

}

resource "azurerm_frontdoor" "frontdoor" {
    name = "bink-frontdoor"
    resource_group_name = azurerm_resource_group.rg.name
    enforce_backend_pools_certificate_name_check = true
    backend_pools_send_receive_timeout_seconds = 120

    tags = var.tags

    frontend_endpoint {
        name = "default"
        host_name = "bink-frontdoor.azurefd.net"
    }

    backend_pool_load_balancing {
        name = "standard"
        additional_latency_milliseconds = 50
    }

    backend_pool_health_probe {
        name = "healthz"
        path = "/healthz"
        protocol = "Https"
        interval_in_seconds = 120
    }

    frontend_endpoint {
        name = "trenette-co-uk"
        host_name = "trenette.co.uk"
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

    frontend_endpoint {
        name = "api-preprod-gb-bink-com"
        host_name = "api.preprod.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    frontend_endpoint {
        name = "api-staging-gb-bink-com"
        host_name = "api.staging.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "uksouth-staging-api"

        backend {
            host_header = "api.staging0.uksouth.bink.sh"
            address = "api.staging0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-api"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-staging-gb-bink-com", "trenette-co-uk"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-api"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "reflector-staging-gb-bink-com"
        host_name = "reflector.staging.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.reflector.id
    }

    backend_pool {
        name = "uksouth-staging-api-reflector"

        backend {
            host_header = "reflector.staging0.uksouth.bink.sh"
            address = "reflector.staging0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-api-reflector"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["reflector-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-api-reflector"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "policies-staging-gb-bink-com"
        host_name = "policies.staging.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-staging-policies"

        backend {
            host_header = "policies.staging0.uksouth.bink.sh"
            address = "policies.staging0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-policies"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["policies-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-policies"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "api-dev-gb-bink-com"
        host_name = "api.dev.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "uksouth-dev-api"

        backend {
            host_header = "api.dev0.uksouth.bink.sh"
            address = "api.dev0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-dev-api"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-dev-api"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "reflector-dev-gb-bink-com"
        host_name = "reflector.dev.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.reflector.id
    }

    backend_pool {
        name = "uksouth-dev-reflector"

        backend {
            host_header = "reflector.dev0.uksouth.bink.sh"
            address = "reflector.dev0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-dev-reflector"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["reflector-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-dev-reflector"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "api-sandbox-gb-bink-com"
        host_name = "api.sandbox.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    frontend_endpoint {
        name = "performance-sandbox-gb-bink-com"
        host_name = "performance.sandbox.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "uksouth-perf-api"

        backend {
            host_header = "api.perf0.uksouth.bink.sh"
            address = "api.perf0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-perf-api"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["performance-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-perf-api"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "oat-sandbox-gb-bink-com"
        host_name = "oat.sandbox.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    frontend_endpoint {
        name = "data-gb-bink-com"
        host_name = "data.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.reflector.id
    }

    backend_pool {
        name = "uksouth-prod-data"

        backend {
            host_header = "data.prod0.uksouth.bink.sh"
            address = "data.prod0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        backend {
            host_header = "data.prod1.uksouth.bink.sh"
            address = "data.prod1.uksouth.bink.sh"
            http_port = 8001
            https_port = 4001
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-prod-data"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["data-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-data"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "link-gb-bink-com"
        host_name = "link.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-prod-link"

        backend {
            host_header = "link.prod0.uksouth.bink.sh"
            address = "link.prod0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        backend {
            host_header = "link.prod1.uksouth.bink.sh"
            address = "link.prod1.uksouth.bink.sh"
            http_port = 8001
            https_port = 4001
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-prod-link"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["link-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-link"
            cache_enabled = false
        }
    }

    backend_pool {
        name = "uksouth-sandbox-oat"
        backend {
            host_header = "oat.sandbox0.uksouth.bink.sh"
            address = "oat.sandbox0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-oat"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["oat-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-oat"
            cache_enabled = false
        }
    }

    backend_pool {
        name = "uksouth-sandbox-sit-barclays"
        backend {
            host_header = "sit-barclays.sandbox0.uksouth.bink.sh"
            address = "sit-barclays.sandbox0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-sit-barclays"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-sit-barclays"
            cache_enabled = false
        }
    }

    backend_pool {
        name = "uksouth-sandbox-sit-lbg"
        backend {
            host_header = "sit-lbg.sandbox0.uksouth.bink.sh"
            address = "sit-lbg.sandbox0.uksouth.bink.sh"
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
        frontend_endpoints = ["sit-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-sit-lbg"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "sit-sandbox-gb-bink-com"
        host_name = "sit.sandbox.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    frontend_endpoint {
        name = "web-gb-bink-com"
        host_name = "web.gb.bink.com"
    }

    routing_rule {
        name = "uksouth-prod-web"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["web-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-web"
            cache_enabled = false
        }
    }

    backend_pool {
        name = "uksouth-prod-web"
        backend {
            host_header = "binkuksouthprodweb.z33.web.core.windows.net"
            address = "binkuksouthprodweb.z33.web.core.windows.net"
            http_port = 80
            https_port = 443
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "custom_https_default" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["default"]
    custom_https_provisioning_enabled = false

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "trenette_co_uk" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["trenette-co-uk"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "trenette"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "api_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "web_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["web-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "policies_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["policies-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "data_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["data-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "link_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["link-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "api_preprod_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-preprod-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "api_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "reflector_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["reflector-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "policies_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["policies-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "api_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "reflector_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["reflector-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "api_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "performance_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["performance-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "sit_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["sit-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "oat_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["oat-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com"
    }

    timeouts {
        update = "120m"
        create = "120m"
        delete = "120m"
    }
}

resource "azurerm_monitor_diagnostic_setting" "diags" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_frontdoor.frontdoor.id
    eventhub_name = "azurefrontdoorpre" # go to a "pre" eventhub for post processing.
    eventhub_authorization_rule_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"

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
