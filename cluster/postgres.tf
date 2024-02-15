locals {
  postgres_secret_json = merge({
    for db in var.postgres.databases : "url_${db}" => "postgresql://${random_pet.pg.id}:${random_password.pg.result}@${azurerm_postgresql_flexible_server.i.fqdn}/${db}?sslmode=require"
    },
    {
      "server_user"     = "${random_pet.pg.id}",
      "server_pass"     = "${random_password.pg.result}",
      "server_host"     = "${azurerm_postgresql_flexible_server.i.fqdn}",
      "url_placeholder" = "postgresql://${random_pet.pg.id}:${random_password.pg.result}@${azurerm_postgresql_flexible_server.i.fqdn}/{}?sslmode=require",
    },
  )
  postgres_secret_uri = merge({
    for db in var.postgres.databases : "${db}" => "postgresql://${random_pet.pg.id}:${random_password.pg.result}@${azurerm_postgresql_flexible_server.i.fqdn}/${db}"
  })
}

resource "azurerm_private_dns_zone" "pg" {
  name                = "private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pg" {
  name                  = "private.postgres.database.azure.com"
  private_dns_zone_name = azurerm_private_dns_zone.pg.name
  virtual_network_id    = azurerm_virtual_network.i.id
  resource_group_name   = azurerm_resource_group.i.name
}

resource "random_string" "pg" {
  length      = 4
  upper       = false
  special     = false
  min_numeric = 2
}
resource "random_pet" "pg" {
  length = 1
}

resource "random_password" "pg" {
  length  = 24
  special = false
}

resource "azurerm_postgresql_flexible_server" "i" {
  name                = "${azurerm_resource_group.i.name}-${random_string.pg.result}"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location

  sku_name = var.postgres.sku
  version  = var.postgres.version

  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id = azurerm_private_dns_zone.pg.id

  administrator_login    = random_pet.pg.id
  administrator_password = random_password.pg.result

  storage_mb            = var.postgres.storage_mb
  backup_retention_days = var.postgres.backup_retention_days

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  }

  dynamic "high_availability" {
    for_each = var.postgres.ha ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.pg]
  lifecycle {
    ignore_changes = [zone, high_availability.0.standby_availability_zone]
  }
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "i" {
  for_each = { for k in var.postgres.entra_id_admins : k.mail => k.object_id }

  server_name         = azurerm_postgresql_flexible_server.i.name
  resource_group_name = azurerm_resource_group.i.name
  tenant_id           = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  object_id           = each.value
  principal_name      = each.key
  principal_type      = "User"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "nightcity" {
  server_name         = azurerm_postgresql_flexible_server.i.name
  resource_group_name = azurerm_resource_group.i.name
  tenant_id           = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  object_id           = azurerm_user_assigned_identity.i["nightcity"].principal_id
  principal_name      = "nightcity"
  principal_type      = "ServicePrincipal"
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.i.id
  value     = "UUID-OSSP,PG_TRGM"
}

resource "azurerm_monitor_diagnostic_setting" "pg" {
  name                       = "loganalytics"
  target_resource_id         = azurerm_postgresql_flexible_server.i.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.i.id

  metric {
    enabled  = true
    category = "AllMetrics"
  }
}

resource "azurerm_role_assignment" "pg_mi" {
  for_each = { for k, v in local.identities : k => v if contains(v["assigned_to"], "pg") }

  scope                = azurerm_postgresql_flexible_server.i.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.i[each.value.identity].principal_id
}

resource "azurerm_role_assignment" "pg_iam" {
  for_each = { for k, v in var.iam : k => v if contains(v["assigned_to"], "pg") }

  scope                = azurerm_postgresql_flexible_server.i.id
  role_definition_name = "Contributor"
  principal_id         = each.key
}

resource "azurerm_key_vault_secret" "pg" {
  name         = "infra-postgres-connection-details"
  key_vault_id = azurerm_key_vault.i.id
  content_type = "application/json"
  value        = jsonencode(local.postgres_secret_json)
  tags = {
    kube_secret_name = "azure-postgres"
  }
  depends_on = [azurerm_key_vault_access_policy.iam_su]
}

resource "azurerm_key_vault_secret" "pg_uri" {
  for_each     = local.postgres_secret_uri
  name         = "infra-postgres-connection-uri-${replace(each.key, "_", "-")}"
  key_vault_id = azurerm_key_vault.i.id
  content_type = "text/plain"
  value        = each.value
  depends_on   = [azurerm_key_vault_access_policy.iam_su]
}
