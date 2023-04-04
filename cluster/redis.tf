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

    capacity = 1
    family = "P"
    sku_name = "Premium"

    enable_non_ssl_port = false
    minimum_tls_version = "1.2"

    public_network_access_enabled = false
    subnet_id = azurerm_subnet.redis.id

    redis_configuration {}

    patch_schedule {
        day_of_week = "Wednesday"
        start_hour_utc = 1
    }
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
