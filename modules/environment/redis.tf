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

resource "azurerm_key_vault_secret" "redis_individual_pass" {
    for_each = var.redis_config

    name = "infra-redis-${each.key}"
    value = jsonencode({
        "host" : azurerm_redis_cache.redis[each.key].hostname,
        "port" : tostring(azurerm_redis_cache.redis[each.key].port),
        "ssl_port" : tostring(azurerm_redis_cache.redis[each.key].ssl_port),
        "password" : azurerm_redis_cache.redis[each.key].primary_access_key,
        "azure_connection_string" : azurerm_redis_cache.redis[each.key].primary_connection_string,
        "uri" : "redis://:${azurerm_redis_cache.redis[each.key].primary_access_key}@${azurerm_redis_cache.redis[each.key].hostname}:${azurerm_redis_cache.redis[each.key].port}/0",
        "uri_ssl" : "rediss://:${azurerm_redis_cache.redis[each.key].primary_access_key}@${azurerm_redis_cache.redis[each.key].hostname}:${azurerm_redis_cache.redis[each.key].ssl_port}/0",
    })
    content_type = "application/json"
    key_vault_id = azurerm_key_vault.infra.id

    tags = {
        k8s_secret_name = "azure-redis-${each.key}"
        k8s_namespaces = "default"
    }
}
