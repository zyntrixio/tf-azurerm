locals {
  # TODO: Populate this automatically
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app#possible_outbound_ip_address_list
  # Updating this causes terraform to try and replace every certificate
  # this is obviously a bad thing.
  # override with: `terraform plan -out=out -target='module.uksouth_frontdoor.azurerm_key_vault.i'`
  acmebot_ips = [
    "20.26.35.150/32",
    "20.26.36.19/32",
    "20.26.36.46/32",
    "20.26.36.174/32",
    "20.26.37.28/32",
    "20.26.37.201/32",
    "20.26.33.69/32",
    "20.26.37.202/32",
    "20.26.38.64/32",
    "20.26.38.93/32",
    "20.26.38.155/32",
    "20.26.38.234/32",
    "20.26.39.174/32",
    "20.26.176.50/32",
    "20.26.176.99/32",
    "20.26.176.109/32",
    "20.26.176.225/32",
    "20.26.177.41/32",
    "20.26.177.47/32",
    "20.26.177.74/32",
    "20.26.177.85/32",
    "20.26.177.112/32",
    "20.26.32.47/32",
    "20.26.177.116/32",
    "20.26.177.144/32",
    "20.26.177.183/32",
    "20.26.32.220/32",
    "20.26.34.236/32",
    "20.26.32.212/32",
    "20.26.177.225/32",
    "20.90.134.20/32"
  ]
}

resource "azurerm_resource_group" "acmebot" {
  name     = "${var.common.location}-acmebot"
  location = var.common.location

  tags = var.common.tags
}

module "keyvault_acmebot" {
  source = "github.com/cpressland/terraform-azurerm-keyvault-acmebot"

  function_app_name     = "bink-${azurerm_resource_group.acmebot.location}-acmebot"
  app_service_plan_name = "bink-${azurerm_resource_group.acmebot.location}-acmebot"
  storage_account_name  = "bink${azurerm_resource_group.acmebot.location}acmebot"
  app_insights_name     = "bink-${azurerm_resource_group.acmebot.location}-acmebot"
  workspace_name        = "bink-${azurerm_resource_group.acmebot.location}-acmebot"
  resource_group_name   = azurerm_resource_group.acmebot.name
  location              = azurerm_resource_group.acmebot.location
  mail_address          = "devops@bink.com"
  vault_uri             = azurerm_key_vault.i.vault_uri

  azure_dns = {
    subscription_id = data.azurerm_client_config.i.subscription_id
  }

  allowed_ip_addresses = concat(
    var.common.secure_origins.ipv4, var.common.secure_origins.ipv6, var.common.secure_origins.checkly
  )

  auth_settings = {
    enabled = true
    active_directory = {
      client_id                  = "06cd27b7-0fe3-4dbc-9f04-690a64927438"
      allowed_audiences          = ["api://06cd27b7-0fe3-4dbc-9f04-690a64927438"]
      tenant_auth_endpoint       = "https://sts.windows.net/a6e2367a-92ea-4e5a-b565-723830bcc095/v2.0",
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    }
  }
}

resource "azurerm_key_vault_access_policy" "acmebot" {
  key_vault_id = azurerm_key_vault.i.id

  tenant_id = data.azurerm_client_config.i.tenant_id
  object_id = module.keyvault_acmebot.principal_id

  certificate_permissions = ["Get", "List", "Create", "Update"]
}

output "acmebot" {
  value = {
    principal_id = module.keyvault_acmebot.principal_id
  }
}

data "azurerm_dns_zone" "bink_com" {
  name                = var.common.dns_zone.name
  resource_group_name = var.common.dns_zone.resource_group
}

resource "azurerm_role_assignment" "acmebot_dns_zone" {
  scope                = data.azurerm_dns_zone.bink_com.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = module.keyvault_acmebot.principal_id
}
