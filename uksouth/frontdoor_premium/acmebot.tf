locals {
    # TODO: Populate this automatically
    acmebot_ips = [
        "20.90.67.150",
        "20.90.67.187",
        "20.90.68.5",
        "20.90.68.16",
        "20.90.68.27",
        "20.90.68.44",
        "20.90.68.47",
        "20.90.68.89",
        "20.90.68.124",
        "20.90.68.170",
        "20.90.68.191",
        "20.90.68.236",
        "20.90.69.2",
        "20.90.69.11",
        "20.90.69.17",
        "20.90.64.230",
        "20.90.69.26",
        "20.90.69.73",
        "20.90.69.92",
        "20.90.66.230",
        "20.90.68.189",
        "20.90.69.124",
        "20.90.69.126",
        "20.90.69.129",
        "20.90.69.133",
        "20.90.69.6",
        "20.90.69.163",
        "20.90.69.192",
        "20.90.69.207",
        "20.90.69.239",
        "51.104.28.82",
    ]
}

resource "azurerm_resource_group" "acmebot" {
    name = "${var.common.location}-acmebot"
    location = var.common.location

    tags = var.common.tags
}

module "keyvault_acmebot" {
    source = "github.com/cpressland/terraform-azurerm-keyvault-acmebot"
    # source = "shibayan/keyvault-acmebot/azurerm"
    # version = "~> 2.0.5"

    function_app_name = "bink-${azurerm_resource_group.acmebot.location}-acmebot"
    app_service_plan_name = "bink-${azurerm_resource_group.acmebot.location}-acmebot"
    storage_account_name = "bink${azurerm_resource_group.acmebot.location}acmebot"
    app_insights_name = "bink-${azurerm_resource_group.acmebot.location}-acmebot"
    workspace_name = "bink-${azurerm_resource_group.acmebot.location}-acmebot"
    resource_group_name = azurerm_resource_group.acmebot.name
    location = azurerm_resource_group.acmebot.location
    mail_address = "devops@bink.com"
    vault_uri = azurerm_key_vault.i.vault_uri

    azure_dns = {
        subscription_id = data.azurerm_client_config.i.subscription_id
    }

    allowed_ip_addresses = concat(
        var.common.secure_origins.ipv4, var.common.secure_origins.ipv6, var.common.secure_origins.checkly
    )

    # TODO: Figure this out, has been manually configured in Portal, think module needs uplift
    # auth_settings = {
    #     enabled = true
    #     issuer = "https://sts.windows.net/a6e2367a-92ea-4e5a-b565-723830bcc095/v2.0"
    #     token_store_enabled = true
    #     active_directory = {
    #         client_id = "04e20ce8-bb3d-4237-9cd9-8ae4c3df7f15"
    #         allowed_audiences = ["api://04e20ce8-bb3d-4237-9cd9-8ae4c3df7f15"]
    #     }
    #     unauthenticated_client_action = "RedirectToLoginPage"
    # }
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
    name = var.common.dns_zone.name
    resource_group_name = var.common.dns_zone.resource_group
}

resource "azurerm_role_assignment" "acmebot_dns_zone" {
  scope = data.azurerm_dns_zone.bink_com.id
  role_definition_name = "DNS Zone Contributor"
  principal_id = module.keyvault_acmebot.principal_id
}
