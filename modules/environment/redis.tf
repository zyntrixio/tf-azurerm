resource "azurerm_redis_cache" "redis" {
    for_each = var.redis_config

    name = each.value["name"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags = var.tags

    capacity = lookup(each.value, "capacity", 1)
    family = lookup(each.value, "family", "C")
    sku_name = lookup(each.value, "sku_name", "Standard")
    enable_non_ssl_port = lookup(each.value, "enable_non_ssl_port", true)
    minimum_tls_version = lookup(each.value, "minimum_tls_version", "1.2")

    redis_configuration {}
}

data "azurerm_redis_cache" "redis" {
    for_each = var.redis_config
    depends_on = [ azurerm_redis_cache.redis ]

    name = each.value["name"]
    resource_group_name = azurerm_resource_group.rg.name
}
