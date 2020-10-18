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

    tags = var.tags

    frontend_endpoint {
        name = "default"
        host_name = "bink-frontdoor.azurefd.net"
        custom_https_provisioning_enabled = false
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

    backend_pool_health_probe {
        name = "grafana"
        path = "/api/health"
        protocol = "Https"
        interval_in_seconds = 120
    }

    frontend_endpoint {
        name = "api-bink-com"
        host_name = "api.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "bink-com-legacy"
            azure_key_vault_certificate_secret_version = "dc0f85cc2abb443a92a9eb062329b9a5"
        }
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    frontend_endpoint {
        name = "api-gb-bink-com"
        host_name = "api.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "api-prod-k8s-uksouth-bink-sh"
        backend {
            host_header = "api.prod.k8s.uksouth.bink.sh"
            address = "api.prod.k8s.uksouth.bink.sh"
            http_port = 80
            https_port = 443
        }

        dynamic "backend" {
            for_each = var.backends["prod"]
            content {
                host_header = backend.value["host_header"]
                address = backend.value["address"]
                http_port = backend.value["http_port"]
                https_port = backend.value["https_port"]
            }
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "api-prod-k8s-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["default", "api-gb-bink-com", "api-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "api-prod-k8s-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "api-prod-k8s-uksouth-bink-sh-content"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/content/*"]
        frontend_endpoints = ["api-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "api-prod-k8s-uksouth-bink-sh"
            cache_enabled = true
            cache_query_parameter_strip_directive = "StripNone"
        }
    }

    frontend_endpoint {
        name = "policies-bink-com"
        host_name = "policies.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "bink-com-legacy"
            azure_key_vault_certificate_secret_version = "dc0f85cc2abb443a92a9eb062329b9a5"
        }
    }

    frontend_endpoint {
        name = "policies-gb-bink-com"
        host_name = "policies.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
    }

    backend_pool {
        name = "policies-uksouth-bink-sh"

        dynamic "backend" {
            for_each = var.backends["prod-policies"]
            content {
                host_header = backend.value["host_header"]
                address = backend.value["address"]
                http_port = backend.value["http_port"]
                https_port = backend.value["https_port"]
            }
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "policies-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["policies-gb-bink-com", "policies-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "policies-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "api-preprod-gb-bink-com"
        host_name = "api.preprod.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "api-preprod-uksouth-bink-sh"

        dynamic "backend" {
            for_each = var.backends["preprod"]
            content {
                host_header = backend.value["host_header"]
                address = backend.value["address"]
                http_port = backend.value["http_port"]
                https_port = backend.value["https_port"]
            }
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "api-preprod-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-preprod-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "api-preprod-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "api-staging-gb-bink-com"
        host_name = "api.staging.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "api-staging-k8s-uksouth-bink-sh"

        dynamic "backend" {
            for_each = var.backends["staging"]
            content {
                host_header = backend.value["host_header"]
                address = backend.value["address"]
                http_port = backend.value["http_port"]
                https_port = backend.value["https_port"]
            }
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "api-staging-k8s-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "api-staging-k8s-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "api-staging-k8s-uksouth-bink-sh-content"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/content/*"]
        frontend_endpoints = ["api-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "api-staging-k8s-uksouth-bink-sh"
            cache_enabled = true
            cache_query_parameter_strip_directive = "StripNone"
        }
    }

    frontend_endpoint {
        name = "policies-staging-gb-bink-com"
        host_name = "policies.staging.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
    }

    backend_pool {
        name = "policies-staging-uksouth-bink-sh"

        dynamic "backend" {
            for_each = var.backends["staging-policies"]
            content {
                host_header = backend.value["host_header"]
                address = backend.value["address"]
                http_port = backend.value["http_port"]
                https_port = backend.value["https_port"]
            }
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "policies-staging-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["policies-staging-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "policies-staging-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "api-dev-gb-bink-com"
        host_name = "api.dev.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "api-dev-k8s-uksouth-bink-sh"

        dynamic "backend" {
            for_each = var.backends["dev"]
            content {
                host_header = backend.value["host_header"]
                address = backend.value["address"]
                http_port = backend.value["http_port"]
                https_port = backend.value["https_port"]
            }
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "api-dev-k8s-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "api-dev-k8s-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    routing_rule {
        name = "api-dev-k8s-uksouth-bink-sh-content"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/content/*"]
        frontend_endpoints = ["api-dev-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "api-dev-k8s-uksouth-bink-sh"
            cache_enabled = true
            cache_query_parameter_strip_directive = "StripNone"
        }
    }

    frontend_endpoint {
        name = "api-sandbox-gb-bink-com"
        host_name = "api.sandbox.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    routing_rule {
        name = "api-sandbox-k8s-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["api-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "api-sandbox-k8s-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    backend_pool {
        name = "api-sandbox-k8s-uksouth-bink-sh"
        backend {
            host_header = "api.sandbox.k8s.uksouth.bink.sh"
            address = "api.sandbox.k8s.uksouth.bink.sh"
            http_port = 80
            https_port = 443
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    frontend_endpoint {
        name = "performance-sandbox-gb-bink-com"
        host_name = "performance.sandbox.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "performance-sandbox-k8s-uksouth-bink-sh"

        dynamic "backend" {
            for_each = var.backends["performance"]
            content {
                host_header = backend.value["host_header"]
                address = backend.value["address"]
                http_port = backend.value["http_port"]
                https_port = backend.value["https_port"]
            }
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "performance-sandbox-k8s-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["performance-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "performance-sandbox-k8s-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "oat-sandbox-gb-bink-com"
        host_name = "oat.sandbox.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
        web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.policy.id
    }

    backend_pool {
        name = "oat-sandbox-k8s-uksouth-bink-sh"
        backend {
            host_header = "oat.sandbox.k8s.uksouth.bink.sh"
            address = "oat.sandbox.k8s.uksouth.bink.sh"
            http_port = 80
            https_port = 443
        }

        load_balancing_name = "standard"
        health_probe_name = "healthz"
    }

    routing_rule {
        name = "oat-sandbox-k8s-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["oat-sandbox-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "oat-sandbox-k8s-uksouth-bink-sh"
            cache_enabled = false
        }
    }

    frontend_endpoint {
        name = "starbug-gb-bink-com"
        host_name = "starbug.gb.bink.com"
        custom_https_provisioning_enabled = true
        custom_https_configuration {
            certificate_source = "AzureKeyVault"
            azure_key_vault_certificate_vault_id = azurerm_key_vault.frontdoor.id
            azure_key_vault_certificate_secret_name = "gb-bink-com"
            azure_key_vault_certificate_secret_version = "6b79a45e4e6e4c3d9ac2585466e7c94d"
        }
    }

    backend_pool {
        name = "starbug-uksouth-bink-sh"
        backend {
            host_header = "starbug.prod0.uksouth.bink.sh"
            address = "starbug.prod0.uksouth.bink.sh"
            http_port = 8000
            https_port = 4000
        }

        load_balancing_name = "standard"
        health_probe_name = "grafana"
    }

    routing_rule {
        name = "starbug-uksouth-bink-sh"
        accepted_protocols = ["Https"]
        patterns_to_match = ["/*"]
        frontend_endpoints = ["starbug-gb-bink-com"]
        forwarding_configuration {
            forwarding_protocol = "HttpsOnly"
            backend_pool_name = "starbug-uksouth-bink-sh"
            cache_enabled = false
        }
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
