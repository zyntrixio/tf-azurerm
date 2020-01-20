resource "azurerm_redis_cache" "redis" {
  name = "bink-dev-uksouth"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity = 0
  family = "C"
  sku_name = "Standard"
  enable_non_ssl_port = true
  minimum_tls_version = "1.2"

  redis_configuration {}
}
