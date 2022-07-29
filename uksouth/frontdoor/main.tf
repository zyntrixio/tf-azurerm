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
        name = "help-gb-bink-com"
        host_name = "help.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-prod-help"

        backend {
            host_header = "help.prod0.uksouth.bink.sh"
            address = "help.prod0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        backend {
            host_header = "help.prod1.uksouth.bink.sh"
            address = "help.prod1.uksouth.bink.sh"
            http_port = 8001
            https_port = 4001
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-prod-help"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["help-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-prod-help"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-prod-help-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["help-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "api-staging-gb-bink-com"
        host_name = "api.staging.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-staging-api"

        backend {
            host_header = "api.staging.uksouth.bink.sh"
            address = "api.staging.uksouth.bink.sh"
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
        frontend_endpoints = ["api-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-api"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-staging-api-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-staging-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "reflector-staging-gb-bink-com"
        host_name = "reflector.staging.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-staging-api-reflector"

        backend {
            host_header = "reflector.staging.uksouth.bink.sh"
            address = "reflector.staging.uksouth.bink.sh"
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

    routing_rule {
        name = "uksouth-staging-api-reflector-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["reflector-staging-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "policies-staging-gb-bink-com"
        host_name = "policies.staging.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-staging-policies"

        backend {
            host_header = "policies.staging.uksouth.bink.sh"
            address = "policies.staging.uksouth.bink.sh"
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

    routing_rule {
        name = "uksouth-staging-policies-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["policies-staging-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "help-staging-gb-bink-com"
        host_name = "help.staging.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-staging-help"

        backend {
            host_header = "help.staging.uksouth.bink.sh"
            address = "help.staging.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-help"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["help-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-help"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-staging-help-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["help-staging-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-staging-docs"
        backend {
            host_header = "api2-docs.staging.uksouth.bink.sh"
            address = "api2-docs.staging.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-docs"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["docs-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-docs"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-staging-docs-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["docs-staging-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "docs-staging-gb-bink-com"
        host_name = "docs.staging.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.secure_origins.id
    }

    frontend_endpoint {
        name = "api-dev-gb-bink-com"
        host_name = "api.dev.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-dev-api"

        backend {
            host_header = "api.dev.uksouth.bink.sh"
            address = "api.dev.uksouth.bink.sh"
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

    routing_rule {
        name = "uksouth-dev-api-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-dev-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "reflector-dev-gb-bink-com"
        host_name = "reflector.dev.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-dev-reflector"

        backend {
            host_header = "reflector.dev.uksouth.bink.sh"
            address = "reflector.dev.uksouth.bink.sh"
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

    routing_rule {
        name = "uksouth-dev-reflector-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["reflector-dev-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-dev-portal"
        backend {
            host_header = "portal.dev.uksouth.bink.sh"
            address = "portal.dev.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-dev-portal"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["portal-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-dev-portal"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-dev-portal-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["portal-dev-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "portal-dev-gb-bink-com"
        host_name = "portal.dev.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-dev-docs"
        backend {
            host_header = "api2-docs.dev.uksouth.bink.sh"
            address = "api2-docs.dev.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-dev-docs"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["docs-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-dev-docs"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-dev-docs-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["docs-dev-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "docs-dev-gb-bink-com"
        host_name = "docs.dev.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.secure_origins.id
    }

    frontend_endpoint {
        name = "api-sandbox-gb-bink-com"
        host_name = "api.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "barclays-oat-sandbox-gb-bink-com"
        host_name = "barclays-oat.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "barclays-sit-sandbox-gb-bink-com"
        host_name = "barclays-sit.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "barclays-sit-reflector-sandbox-gb-bink-com"
        host_name = "barclays-sit-reflector.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "lloyds-sit-sandbox-gb-bink-com"
        host_name = "lloyds-sit.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "lloyds-sit-reflector-sandbox-gb-bink-com"
        host_name = "lloyds-sit-reflector.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "squaremeal-sandbox-gb-bink-com"
        host_name = "squaremeal.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "perf-api-v1-sandbox-gb-bink-com"
        host_name = "perf-api-v1.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "perf-api-v2-sandbox-gb-bink-com"
        host_name = "perf-api-v2.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "perf-bpl-sandbox-gb-bink-com"
        host_name = "perf-bpl.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "perf-txm-sandbox-gb-bink-com"
        host_name = "perf-txm.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "performance-sandbox-gb-bink-com"
        host_name = "performance.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "perf-data-sandbox-gb-bink-com"
        host_name = "perf-data.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "perf-data-reflector-sandbox-gb-bink-com"
        host_name = "perf-data-reflector.sandbox.gb.bink.com"
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

    routing_rule {
        name = "uksouth-perf-api-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["performance-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }


    frontend_endpoint {
        name = "oat-sandbox-gb-bink-com"
        host_name = "oat.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "data-gb-bink-com"
        host_name = "data.gb.bink.com"
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.secure_origins.id
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

    routing_rule {
        name = "uksouth-prod-data-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["data-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
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

    routing_rule {
        name = "uksouth-prod-link-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["link-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "link-staging-gb-bink-com"
        host_name = "link.staging.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-staging-link"

        backend {
            host_header = "link.staging.uksouth.bink.sh"
            address = "link.staging.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-link"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["link-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-link"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-staging-link-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["link-staging-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-staging-portal"
        backend {
            host_header = "portal.staging.uksouth.bink.sh"
            address = "portal.staging.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-portal"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["portal-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-portal"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-staging-portal-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["portal-staging-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "portal-staging-gb-bink-com"
        host_name = "portal.staging.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-sandbox-oat"
        backend {
            host_header = "barclays-oat.sandbox.uksouth.bink.sh"
            address = "barclays-oat.sandbox.uksouth.bink.sh"
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
        frontend_endpoints = ["oat-sandbox-gb-bink-com", "barclays-oat-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-oat"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-oat-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["oat-sandbox-gb-bink-com", "barclays-oat-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-sandbox-sit-barclays"
        backend {
            host_header = "barclays-sit.sandbox.uksouth.bink.sh"
            address = "barclays-sit.sandbox.uksouth.bink.sh"
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
        frontend_endpoints = ["api-sandbox-gb-bink-com", "barclays-sit-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-sit-barclays"
            cache_enabled = false
        }
    }

    backend_pool {
        name = "uksouth-sandbox-barclays-sit-reflector"
        backend {
            host_header = "barclays-sit-reflector.sandbox.uksouth.bink.sh"
            address = "barclays-sit-reflector.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-barclays-sit-reflector"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["barclays-sit-reflector-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-barclays-sit-reflector"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-barclays-sit-reflector-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["barclays-sit-reflector-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    routing_rule {
        name = "uksouth-sandbox-sit-barclays-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-sandbox-gb-bink-com", "barclays-sit-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    routing_rule {
        name = "uksouth-sandbox-perf-api-v1"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-api-v1-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-perf-api-v1"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-perf-api-v1-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-api-v1-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-sandbox-perf-api-v1"
        backend {
            host_header = "perf-api-v1.sandbox.uksouth.bink.sh"
            address = "perf-api-v1.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-perf-api-v2"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-api-v2-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-perf-api-v2"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-perf-api-v2-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-api-v2-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-sandbox-perf-api-v2"
        backend {
            host_header = "perf-api-v2.sandbox.uksouth.bink.sh"
            address = "perf-api-v2.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-perf-bpl"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-bpl-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-perf-bpl"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-perf-bpl-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-bpl-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-sandbox-perf-bpl"
        backend {
            host_header = "perf-bpl.sandbox.uksouth.bink.sh"
            address = "perf-bpl.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-perf-txm"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-txm-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-perf-txm"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-perf-txm-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-txm-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-sandbox-perf-txm"
        backend {
            host_header = "perf-txm.sandbox.uksouth.bink.sh"
            address = "perf-txm.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
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
            "sit-sandbox-gb-bink-com",
            "lloyds-sit-sandbox-gb-bink-com",
            "squaremeal-sandbox-gb-bink-com",
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
        frontend_endpoints = ["sit-sandbox-gb-bink-com", "lloyds-sit-sandbox-gb-bink-com"]
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
        name = "perf-bpl-reflector-sandbox-gb-bink-com"
        host_name = "perf-bpl-reflector.sandbox.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-sandbox-perf-data-reflector"
        backend {
            host_header = "perf-data-reflector.sandbox.uksouth.bink.sh"
            address = "perf-data-reflector.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-perf-data-reflector"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-data-reflector-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-perf-data-reflector"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-perf-data"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-data-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-perf-data"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-perf-data-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-data-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "uksouth-sandbox-perf-data"
        backend {
            host_header = "perf-data.sandbox.uksouth.bink.sh"
            address = "perf-data.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    backend_pool {
        name = "uksouth-sandbox-perf-bpl-reflector"
        backend {
            host_header = "perf-bpl-reflector.sandbox.uksouth.bink.sh"
            address = "perf-bpl-reflector.sandbox.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-sandbox-perf-bpl-reflector"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-bpl-reflector-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-sandbox-perf-bpl-reflector"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-sandbox-perf-bpl-reflector-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["perf-bpl-reflector-sandbox-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "sit-sandbox-gb-bink-com"
        host_name = "sit.sandbox.gb.bink.com"
    }

    frontend_endpoint {
        name = "wallet-gb-bink-com"
        host_name = "wallet.gb.bink.com"
    }

    frontend_endpoint {
        name = "wasabi-gb-bink-com"
        host_name = "wasabi.gb.bink.com"
    }

    frontend_endpoint {
        name = "wallet-staging-gb-bink-com"
        host_name = "wallet.staging.gb.bink.com"
    }

    frontend_endpoint {
        name = "wasabi-staging-gb-bink-com"
        host_name = "wasabi.staging.gb.bink.com"
    }

    frontend_endpoint {
        name = "wallet-dev-gb-bink-com"
        host_name = "wallet.dev.gb.bink.com"
    }

    frontend_endpoint {
        name = "wasabi-dev-gb-bink-com"
        host_name = "wasabi.dev.gb.bink.com"
    }

    routing_rule {
        name = "binkweb-http-to-https"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = [
            "wallet-gb-bink-com",
            "wasabi-gb-bink-com",
            "wallet-staging-gb-bink-com",
            "wasabi-staging-gb-bink-com",
            "wallet-dev-gb-bink-com",
            "wasabi-dev-gb-bink-com",
        ]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    backend_pool {
        name = "dev-binkweb-bink"
        backend {
            host_header = "web-bink.dev.uksouth.bink.sh"
            address = "web-bink.dev.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "dev-binkweb-bink"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["wallet-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "dev-binkweb-bink"
            cache_enabled = false
        }
    }

    backend_pool {
        name = "dev-binkweb-wasabi"
        backend {
            host_header = "web-wasabi.dev.uksouth.bink.sh"
            address = "web-wasabi.dev.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "dev-binkweb-wasabi"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["wasabi-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "dev-binkweb-wasabi"
            cache_enabled = false
        }
    }


    frontend_endpoint {
        name = "bpl-dev-gb-bink-com"
        host_name = "bpl.dev.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-dev-bpl"
        backend {
            host_header = "bpl.dev.uksouth.bink.sh"
            address = "bpl.dev.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-dev-bpl"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["bpl-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-dev-bpl"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-dev-bpl-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["bpl-dev-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }


    frontend_endpoint {
        name = "bpl-staging-gb-bink-com"
        host_name = "bpl.staging.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-staging-bpl"
        backend {
            host_header = "bpl.staging.uksouth.bink.sh"
            address = "bpl.staging.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-bpl"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["bpl-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-bpl"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-staging-bpl-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["bpl-staging-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "data-dashboard-dev-gb-bink-com"
        host_name = "data-dashboard.dev.gb.bink.com"
    }

    backend_pool {
        name = "uksouth-dev-data-dashboard"
        backend {
            host_header = "data-dashboard.dev.uksouth.bink.sh"
            address = "data-dashboard.dev.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-dev-data-dashboard"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["data-dashboard-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-dev-data-dashboard"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-dev-data-dashboard-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["data-dashboard-dev-gb-bink-com"]
        redirect_configuration {
            redirect_type = "Found"
            redirect_protocol = "HttpsOnly"
        }
    }

    frontend_endpoint {
        name = "data-dashboard-staging-gb-bink-com"
        host_name = "data-dashboard.staging.gb.bink.com"
    }
    backend_pool {
        name = "uksouth-staging-data-dashboard"
        backend {
            host_header = "data-dashboard.staging.uksouth.bink.sh"
            address = "data-dashboard.staging.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }
        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "uksouth-staging-data-dashboard"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["data-dashboard-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "uksouth-staging-data-dashboard"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "uksouth-staging-data-dashboard-http"
        accepted_protocols = ["Http"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["data-dashboard-staging-gb-bink-com"]
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

resource "azurerm_frontdoor_custom_https_configuration" "help_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["help-gb-bink-com"]
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

resource "azurerm_frontdoor_custom_https_configuration" "data_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["data-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "link_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["link-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "link_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["link-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "api_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "reflector_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["reflector-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "policies_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["policies-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "help_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["help-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "docs_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["docs-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "api_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "reflector_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["reflector-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "portal_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["portal-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "docs_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["docs-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "api_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["api-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "performance_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["performance-sandbox-gb-bink-com"]
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

resource "azurerm_frontdoor_custom_https_configuration" "sit_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["sit-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "oat_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["oat-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "barclays_sit_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["barclays-sit-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "barclays_oat_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["barclays-oat-sandbox-gb-bink-com"]
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

resource "azurerm_frontdoor_custom_https_configuration" "squaremeal_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["squaremeal-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "perf_data_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["perf-data-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "perf_data_reflector_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["perf-data-reflector-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "perf_api_v1_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["perf-api-v1-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "perf_api_v2_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["perf-api-v2-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "perf_bpl_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["perf-bpl-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "perf_txm_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["perf-txm-sandbox-gb-bink-com"]
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

resource "azurerm_frontdoor_custom_https_configuration" "wallet_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["wallet-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "wasabi_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["wasabi-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "portal_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["portal-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "wallet_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["wallet-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "wasabi_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["wasabi-dev-gb-bink-com"]
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

resource "azurerm_frontdoor_custom_https_configuration" "perf_bpl_reflector_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["perf-bpl-reflector-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "barclays_sit_reflector_sandbox_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["barclays-sit-reflector-sandbox-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "bpl_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["bpl-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "bpl_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["bpl-staging-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "data_dashboard_dev_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["data-dashboard-dev-gb-bink-com"]
    custom_https_provisioning_enabled = true

    custom_https_configuration {
        certificate_source = "AzureKeyVault"
        azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
        azure_key_vault_certificate_secret_name = "gb-bink-com-2022-2023"
    }
}

resource "azurerm_frontdoor_custom_https_configuration" "data_dashboard_staging_gb_bink_com" {
    frontend_endpoint_id = azurerm_frontdoor.frontdoor.frontend_endpoints["data-dashboard-staging-gb-bink-com"]
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
