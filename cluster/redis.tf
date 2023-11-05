resource "random_string" "rd" {
    length = 4
    upper = false
    special = false
    min_numeric = 2
}

resource "azurerm_redis_cache" "i" {
    count = var.redis.enabled ? 1 : 0

    name = "${azurerm_resource_group.i.name}-${random_string.rd.result}"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name

    redis_version = 6

    capacity = var.redis.capacity
    family = var.redis.family
    sku_name = var.redis.sku_name

    enable_non_ssl_port = false
    minimum_tls_version = "1.2"

    public_network_access_enabled = false
    subnet_id = var.redis.sku_name == "Premium" ? azurerm_subnet.redis.id : null

    redis_configuration {}

    patch_schedule {
        day_of_week = "Wednesday"
        start_hour_utc = 1
    }
}

resource "azurerm_private_dns_zone" "rd" {
    count = var.redis.enabled && var.redis.sku_name == "Premium" ? 0 : 1
    name = "redis.cache.windows.net"
    resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "rd" {
    count = var.redis.enabled && var.redis.sku_name == "Premium" ? 0 : 1
    name = "redis.cache.windows.net"
    resource_group_name = azurerm_resource_group.i.name
    private_dns_zone_name = azurerm_private_dns_zone.rd[0].name
    virtual_network_id = azurerm_virtual_network.i.id
}

resource "azurerm_private_endpoint" "rd" {
    count = var.redis.enabled && var.redis.sku_name != "Premium" ? 1 : 0
    name = "${azurerm_resource_group.i.name}-${random_string.rd.result}"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
    subnet_id = azurerm_subnet.redis.id

    private_dns_zone_group {
        name = "redis.cache.windows.net"
        private_dns_zone_ids = [azurerm_private_dns_zone.rd[0].id]
    }

    private_service_connection {
        name = "${azurerm_resource_group.i.name}-${random_string.rd.result}"
        private_connection_resource_id = azurerm_redis_cache.i[0].id
        is_manual_connection = false
        subresource_names = ["redisCache"]
    }
}

resource "azurerm_key_vault_secret" "rd" {
    count = var.redis.enabled && var.keyvault.enabled ? 1 : 0

    name = "infra-redis-connection-details"
    key_vault_id = azurerm_key_vault.i[0].id
    content_type = "application/json"
    value = jsonencode({
        "url_primary" = "rediss://:${azurerm_redis_cache.i[0].primary_access_key}@${azurerm_redis_cache.i[0].hostname}:${azurerm_redis_cache.i[0].ssl_port}/0",
        "url_secondary" = "rediss://:${azurerm_redis_cache.i[0].secondary_access_key}@${azurerm_redis_cache.i[0].hostname}:${azurerm_redis_cache.i[0].ssl_port}/0",
        "host" = azurerm_redis_cache.i[0].hostname
        "port" = tostring(azurerm_redis_cache.i[0].ssl_port)
        "access_key_primary" = azurerm_redis_cache.i[0].primary_access_key
        "access_key_secondary" = azurerm_redis_cache.i[0].secondary_access_key
    })
    tags = {
        kube_secret_name = "azure-redis"
    }

    depends_on = [ azurerm_key_vault_access_policy.iam_su ]
}

resource "azurerm_role_assignment" "rd_mi" {
    for_each = {
        for k, v in local.identities : k => v
            if contains(v["assigned_to"], "rd") &&
            var.redis.enabled
    }

    scope = azurerm_redis_cache.i[0].id
    role_definition_name = "Contributor"
    principal_id = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "rd_iam" {
    for_each = {
        for k, v in var.iam : k => v
            if contains(v["assigned_to"], "rd") &&
            var.redis.enabled
    }

    scope = azurerm_redis_cache.i[0].id
    role_definition_name = "Contributor"
    principal_id = each.key
}

resource "azurerm_monitor_diagnostic_setting" "rd" {
    count = var.redis.enabled && var.loganalytics.enabled ? 1 : 0

    name = "loganalytics"
    target_resource_id = azurerm_redis_cache.i[0].id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

    enabled_log { category = "ConnectedClientList" }
    metric {
        category = "AllMetrics"
        enabled = false
    }
}
