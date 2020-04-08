resource "azurerm_redis_cache" "redis" {
  name = "bink-staging-uksouth"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity = 1
  family = "C"
  sku_name = "Standard"
  enable_non_ssl_port = true
  minimum_tls_version = "1.2"

  redis_configuration {}
}

resource "azurerm_redis_firewall_rule" "workers" {
  name = "uksouth"
  redis_cache_name = azurerm_redis_cache.redis.name
  resource_group_name = azurerm_resource_group.rg.name
  start_ip = "51.132.44.240"
  end_ip = "51.132.44.255"
}

resource "azurerm_redis_firewall_rule" "binkhq" {
  name = "binkhq"
  redis_cache_name = azurerm_redis_cache.redis.name
  resource_group_name = azurerm_resource_group.rg.name
  start_ip = "194.74.152.11"
  end_ip = "194.74.152.11"
}