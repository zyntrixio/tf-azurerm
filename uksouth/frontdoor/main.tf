provider "azurerm" {
  version = "~> 2.2.0"
  subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
  client_id = "98e2ee67-a52d-40fc-9b39-155887530a7b"
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

terraform {
  backend "azurerm" {
    storage_account_name = "binkitops"
    container_name = "terraform"
    key = "frontdoor.tfstate"
  }
}

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
      object_id = "48aca6b1-4d56-4a15-bc92-8aa9d97300df" # Chris Pressland

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

  access_policy {
      tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
      object_id = "de80162c-8e52-466b-affd-f3ccc0a66d5d" # Tom Winchester

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

  tags = var.tags
}

resource "azurerm_frontdoor" "frontdoor" {
  name = "bink-frontdoor"
  resource_group_name = azurerm_resource_group.rg.name
  enforce_backend_pools_certificate_name_check = true

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

### Production ###

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
  }

  backend_pool {
    name = "api-prod-k8s-uksouth-bink-sh"
    backend {
      host_header = "api.prod.k8s.uksouth.bink.sh"
      address     = "api.prod.k8s.uksouth.bink.sh"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "standard"
    health_probe_name   = "healthz"
  }

  routing_rule {
    name = "api-prod-k8s-uksouth-bink-sh"
    accepted_protocols = ["Https"]
    patterns_to_match = ["/*"]
    frontend_endpoints = ["default", "api-gb-bink-com"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name  = "api-prod-k8s-uksouth-bink-sh"
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
      backend_pool_name  = "api-prod-k8s-uksouth-bink-sh"
      cache_enabled = true
    }
  }

### Preprod ###

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
  }

  backend_pool {
    name = "api-preprod-k8s-uksouth-bink-sh"
    backend {
      host_header = "api.preprod.k8s.uksouth.bink.sh"
      address     = "api.preprod.k8s.uksouth.bink.sh"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "standard"
    health_probe_name   = "healthz"
  }


### Staging ###

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
  }

  backend_pool {
    name = "api-staging-k8s-uksouth-bink-sh"
    backend {
      host_header = "api.staging.k8s.uksouth.bink.sh"
      address     = "api.staging.k8s.uksouth.bink.sh"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "standard"
    health_probe_name   = "healthz"
  }

  routing_rule {
    name = "api-staging-k8s-uksouth-bink-sh"
    accepted_protocols = ["Https"]
    patterns_to_match = ["/*"]
    frontend_endpoints = ["api-staging-gb-bink-com"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name  = "api-staging-k8s-uksouth-bink-sh"
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
      backend_pool_name  = "api-staging-k8s-uksouth-bink-sh"
      cache_enabled = true
    }
  }


### Dev ###

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
  }

  backend_pool {
    name = "api-dev-k8s-uksouth-bink-sh"
    backend {
      host_header = "api.dev.k8s.uksouth.bink.sh"
      address     = "api.dev.k8s.uksouth.bink.sh"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "standard"
    health_probe_name   = "healthz"
  }

  routing_rule {
    name = "api-dev-k8s-uksouth-bink-sh"
    accepted_protocols = ["Https"]
    patterns_to_match = ["/*"]
    frontend_endpoints = ["api-dev-gb-bink-com"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name  = "api-dev-k8s-uksouth-bink-sh"
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
      backend_pool_name  = "api-dev-k8s-uksouth-bink-sh"
      cache_enabled = true
    }
  }

### Sandbox ###

  # TODO:
  # api.sandbox.gb.bink.com - Sandbox - to replace performance.sandbox.gb.bink.com after performance testing is complete

  backend_pool {
    name = "api-sandbox-k8s-uksouth-bink-sh"
    backend {
      host_header = "api.sandbox.k8s.uksouth.bink.sh"
      address     = "api.sandbox.k8s.uksouth.bink.sh"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "standard"
    health_probe_name   = "healthz"
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
  }

  backend_pool {
    name = "performance-sandbox-k8s-uksouth-bink-sh"
    backend {
      host_header = "performance.sandbox.k8s.uksouth.bink.sh"
      address     = "performance.sandbox.k8s.uksouth.bink.sh"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "standard"
    health_probe_name   = "healthz"
  }

  routing_rule {
    name = "performance-sandbox-k8s-uksouth-bink-sh"
    accepted_protocols = ["Https"]
    patterns_to_match = ["/*"]
    frontend_endpoints = ["performance-sandbox-gb-bink-com"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name  = "performance-sandbox-k8s-uksouth-bink-sh"
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
  }

  backend_pool {
    name = "oat-sandbox-k8s-uksouth-bink-sh"
    backend {
      host_header = "oat.sandbox.k8s.uksouth.bink.sh"
      address     = "oat.sandbox.k8s.uksouth.bink.sh"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "standard"
    health_probe_name   = "healthz"
  }

  routing_rule {
    name = "oat-sandbox-k8s-uksouth-bink-sh"
    accepted_protocols = ["Https"]
    patterns_to_match = ["/*"]
    frontend_endpoints = ["oat-sandbox-gb-bink-com"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name  = "oat-sandbox-k8s-uksouth-bink-sh"
      cache_enabled = false
    }
  }

  tags = var.tags
}
