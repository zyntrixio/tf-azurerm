locals {
  postgres_identity_map = merge(flatten([
    for pg_key, pg_value in var.postgres : {
      for mi_key, mi_value in var.managed_identities :
      "${pg_key}-${mi_key}" => { postgres_server = pg_key, identity = mi_key }
    if contains(mi_value["assigned_to"], "pg") }
  ])...)
  postgres_iam_map = merge(flatten([
    for pg_key, pg_value in var.postgres : {
      for iam_key, iam_value in var.iam :
      "${pg_key}-${iam_key}" => { postgres_server = pg_key, identity = iam_key }
    if contains(iam_value["assigned_to"], "pg") }
  ])...)
  postgres_entra_admins = merge(flatten([
    for pg_key, pg_value in var.postgres : {
      for admin in pg_value.entra_id_admins :
      "${pg_key}-${admin.mail}" => {
        postgres_server = pg_key,
        email           = admin.mail,
        object_id       = admin.object_id,
    } }
  ])...)
  postgres_secret_json = merge(flatten([[
    for k, v in var.postgres :
    k == "core" ? {
      for db in v.databases : "url_${db}" => "postgresql://${random_pet.pg[k].id}:${random_password.pg[k].result}@${azurerm_postgresql_flexible_server.i[k].fqdn}/${db}?sslmode=require"
      } : {
      for db in v.databases : "url_${k}_${db}" => "postgresql://${random_pet.pg[k].id}:${random_password.pg[k].result}@${azurerm_postgresql_flexible_server.i[k].fqdn}/${db}?sslmode=require"
    }
    ], [
    for k, v in var.postgres :
    k == "core" ? {
      "server_user"     = "${random_pet.pg[k].id}",
      "server_pass"     = "${random_password.pg[k].result}",
      "server_host"     = "${azurerm_postgresql_flexible_server.i[k].fqdn}",
      "url_placeholder" = "postgresql://${random_pet.pg[k].id}:${random_password.pg[k].result}@${azurerm_postgresql_flexible_server.i[k].fqdn}/{}?sslmode=require",
      } : {
      "${k}_server_user"     = "${random_pet.pg[k].id}",
      "${k}_server_pass"     = "${random_password.pg[k].result}",
      "${k}_server_host"     = "${azurerm_postgresql_flexible_server.i[k].fqdn}",
      "${k}_url_placeholder" = "postgresql://${random_pet.pg[k].id}:${random_password.pg[k].result}@${azurerm_postgresql_flexible_server.i[k].fqdn}/{}?sslmode=require",
    }
  ]])...)
  postgres_secret_uri = merge(flatten([
    for k, v in var.postgres : {
      for db in v.databases : "${k}-${db}" => "postgresql://${random_pet.pg[k].id}:${random_password.pg[k].result}@${azurerm_postgresql_flexible_server.i[k].fqdn}/${db}"
    }
  ])...)
}

output "test" {
  value = local.postgres_entra_admins
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
  for_each    = var.postgres
  length      = 4
  upper       = false
  special     = false
  min_numeric = 2
}

resource "random_pet" "pg" {
  for_each = var.postgres
  length   = 1
}

resource "random_password" "pg" {
  for_each = var.postgres
  length   = 24
  special  = false
}

resource "azurerm_postgresql_flexible_server" "i" {
  for_each = var.postgres

  name                = "${azurerm_resource_group.i.name}-${random_string.pg[each.key].result}"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location

  sku_name = each.value.sku
  version  = each.value.version

  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id = azurerm_private_dns_zone.pg.id

  administrator_login    = random_pet.pg[each.key].id
  administrator_password = random_password.pg[each.key].result

  storage_mb            = each.value.storage_mb
  backup_retention_days = each.value.backup_retention_days

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  }

  dynamic "high_availability" {
    for_each = each.value.ha ? [1] : []
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
  for_each = local.postgres_entra_admins

  server_name         = azurerm_postgresql_flexible_server.i[each.value.postgres_server].name
  resource_group_name = azurerm_resource_group.i.name
  tenant_id           = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  object_id           = each.value.object_id
  principal_name      = each.value.email
  principal_type      = "User"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "nightcity" {
  for_each = var.postgres

  server_name         = azurerm_postgresql_flexible_server.i[each.key].name
  resource_group_name = azurerm_resource_group.i.name
  tenant_id           = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  object_id           = azurerm_user_assigned_identity.i["nightcity"].principal_id
  principal_name      = "nightcity"
  principal_type      = "ServicePrincipal"
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  for_each = var.postgres

  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.i[each.key].id
  value     = "UUID-OSSP,PG_TRGM"
}

resource "azurerm_monitor_diagnostic_setting" "pg" {
  for_each = var.loganalytics.enabled ? var.postgres : {}

  name                       = "loganalytics"
  target_resource_id         = azurerm_postgresql_flexible_server.i[each.key].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

  metric {
    enabled  = true
    category = "AllMetrics"
  }
}

resource "azurerm_role_assignment" "pg_mi" {
  for_each = local.postgres_identity_map

  scope                = azurerm_postgresql_flexible_server.i[each.value.postgres_server].id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.i[each.value.identity].principal_id
}

resource "azurerm_role_assignment" "pg_iam" {
  for_each = local.postgres_iam_map

  scope                = azurerm_postgresql_flexible_server.i[each.value.postgres_server].id
  role_definition_name = "Contributor"
  principal_id         = each.value.identity
}

resource "azurerm_key_vault_secret" "pg" {
  name         = "infra-postgres-connection-details"
  key_vault_id = azurerm_key_vault.i[0].id
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
  key_vault_id = azurerm_key_vault.i[0].id
  content_type = "text/plain"
  value        = each.value
  depends_on   = [azurerm_key_vault_access_policy.iam_su]
}
