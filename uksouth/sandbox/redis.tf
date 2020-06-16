resource "azurerm_redis_cache" "performance" {
    name = "bink-performance-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    capacity = 3
    family = "C"
    sku_name = "Standard"
    enable_non_ssl_port = true
    minimum_tls_version = "1.2"

    redis_configuration {}
}

resource "azurerm_redis_firewall_rule" "performance" {
    name = "uksouth"
    redis_cache_name = azurerm_redis_cache.performance.name
    resource_group_name = azurerm_resource_group.rg.name
    start_ip = "51.132.44.240"
    end_ip = "51.132.44.255"
}

resource "azurerm_redis_cache" "oat" {
    name = "bink-oat-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    capacity = 0
    family = "C"
    sku_name = "Standard"
    enable_non_ssl_port = true
    minimum_tls_version = "1.2"

    redis_configuration {}
}

resource "azurerm_redis_firewall_rule" "oat" {
    name = "uksouth"
    redis_cache_name = azurerm_redis_cache.oat.name
    resource_group_name = azurerm_resource_group.rg.name
    start_ip = "51.132.44.240"
    end_ip = "51.132.44.255"
}

resource "azurerm_redis_cache" "sandbox" {
    name = "bink-sandbox-uksouth"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    capacity = 0
    family = "C"
    sku_name = "Standard"
    enable_non_ssl_port = true
    minimum_tls_version = "1.2"

    redis_configuration {}
}

resource "azurerm_redis_firewall_rule" "sandbox" {
    name = "uksouth"
    redis_cache_name = azurerm_redis_cache.sandbox.name
    resource_group_name = azurerm_resource_group.rg.name
    start_ip = "51.132.44.240"
    end_ip = "51.132.44.255"
}
