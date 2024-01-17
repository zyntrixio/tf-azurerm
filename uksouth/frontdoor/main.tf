terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
    }
    required_version = ">= 1.3.3"
}

locals {
    # The below list should be dynamically generated, but alas, this was easier given the
    # time constaints
    private_link_ids = {
        "uksouth_ait" = "/subscriptions/0b92124d-e5fe-4c9a-a898-1fdf02502e01/resourceGroups/uksouth-ait-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-ait"
        "uksouth_dev" = "/subscriptions/6a36a6fd-e97c-42f2-88ff-2484d8165f53/resourceGroups/uksouth-dev-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-dev"
        "uksouth_staging" = "/subscriptions/e28b2912-1f6d-4ac7-9cd7-443d73876e10/resourceGroups/uksouth-staging-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-staging"
        "uksouth_sandbox" = "/subscriptions/64678f82-1a1b-4096-b7e9-41b1bdcdc024/resourceGroups/uksouth-sandbox-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-sandbox"
        "uksouth_lloyds" = "/subscriptions/64678f82-1a1b-4096-b7e9-41b1bdcdc024/resourceGroups/uksouth-lloyds-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-lloyds"
        "uksouth_retail" = "/subscriptions/64678f82-1a1b-4096-b7e9-41b1bdcdc024/resourceGroups/uksouth-retail-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-retail"
        "uksouth_prod" = "/subscriptions/42706d13-8023-4b0c-b98a-1a562cb9ac40/resourceGroups/uksouth-prod-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-prod"
    }

    origin_groups = {
        # AIT Environment
        "uksouth_ait_starbug" = {
            "endpoint" = "uksouth-ait"
            "domain" = "starbug.ait.gb.bink.com"
            "cert_name" = "acmebot-ait-gb-bink-com"
            "origins" = {"starbug.ait.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_ait}}
        }
        "uksouth_ait_configuration" = {
            "endpoint" = "uksouth-ait"
            "domain" = "configuration.ait.gb.bink.com"
            "cert_name" = "acmebot-ait-gb-bink-com"
            "origins" = {"configuration.ait.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_ait}}
        }
        # Dev Environment
        "uksouth_dev_api" = {
            "endpoint" = "uksouth-dev"
            "domain" = "api.dev.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"api.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_bpl" = {
            "endpoint" = "uksouth-dev"
            "domain" = "bpl.dev.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"bpl.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_rewards" = {
            "endpoint" = "uksouth-dev"
            "domain" = "rewards.dev.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"rewards.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_reflector" = {
            "endpoint" = "uksouth-dev"
            "domain" = "reflector.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"reflector.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_audit" = {
            "endpoint" = "uksouth-dev"
            "domain" = "audit.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"audit.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_docs" = {
            "endpoint" = "uksouth-dev"
            "domain" = "docs.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"docs.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_portal" = {
            "endpoint" = "uksouth-dev"
            "domain" = "portal.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"portal.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_wallet" = {
            "endpoint" = "uksouth-dev"
            "domain" = "wallet.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"web-bink.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_wasabi" = {
            "endpoint" = "uksouth-dev"
            "domain" = "wasabi.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"web-wasabi.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_cosmos" = {
            "endpoint" = "uksouth-dev"
            "domain" = "cosmos.dev.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"cosmos.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_retailer" = {
            "endpoint" = "uksouth-dev"
            "domain" = "retailer.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"retailer.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        # Staging Envrionment
        "uksouth_staging_api" = {
            "endpoint" = "uksouth-staging"
            "domain" = "api.staging.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"api.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_bpl" = {
            "endpoint" = "uksouth-staging"
            "domain" = "bpl.staging.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"bpl.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_rewards" = {
            "endpoint" = "uksouth-staging"
            "domain" = "rewards.staging.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"rewards.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_reflector" = {
            "endpoint" = "uksouth-staging"
            "domain" = "reflector.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"reflector.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_audit" = {
            "endpoint" = "uksouth-staging"
            "domain" = "audit.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"audit.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_policies" = {
            "endpoint" = "uksouth-staging"
            "domain" = "policies.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"policies.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_docs" = {
            "endpoint" = "uksouth-staging"
            "domain" = "docs.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"docs.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_portal" = {
            "endpoint" = "uksouth-staging"
            "domain" = "portal.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"portal.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_wallet" = {
            "endpoint" = "uksouth-staging"
            "domain" = "wallet.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"web-bink.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_wasabi" = {
            "endpoint" = "uksouth-staging"
            "domain" = "wasabi.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"web-wasabi.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_cosmos" = {
            "endpoint" = "uksouth-staging"
            "domain" = "cosmos.staging.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"cosmos.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_retailer" = {
            "endpoint" = "uksouth-staging"
            "domain" = "retailer.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"retailer.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_prefect" = {
            "endpoint" = "uksouth-staging"
            "domain" = "prefect.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"prefect.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_airbyte" = {
            "endpoint" = "uksouth-staging"
            "domain" = "airbyte.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"airbyte.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }

        # Sandbox Environment
        "uksouth_sandbox_api" = {
            "endpoint" = "uksouth-sandbox",
            "domain" = "api.sandbox.gb.bink.com"
            "cert_name" = "acmebot-sandbox-gb-bink-com"
            "origins" = {"api.sandbox.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_sandbox}}
        }
        "uksouth_sandbox_retailer" = {
            "endpoint" = "uksouth-sandbox",
            "domain" = "retailer.sandbox.gb.bink.com"
            "cert_name" = "acmebot-sandbox-gb-bink-com"
            "origins" = {"retailer.sandbox.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_sandbox}}
        }

        # Lloyds Environment
        "uksouth_lloyds_api" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "api.lloyds.gb.bink.com"
            "cert_name" = "acmebot-lloyds-gb-bink-com"
            "origins" = {"api.lloyds.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_lloyds}}
        }
        "uksouth_lloyds_docs" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "docs.lloyds.gb.bink.com"
            "cert_name" = "acmebot-lloyds-gb-bink-com"
            "origins" = {"docs.lloyds.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_lloyds}}
        }
        "uksouth_lloyds_reflector" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "reflector.lloyds.gb.bink.com"
            "cert_name" = "acmebot-lloyds-gb-bink-com"
            "origins" = {"reflector.lloyds.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_lloyds}}
        }
        "uksouth_lloyds_audit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "audit.lloyds.gb.bink.com"
            "cert_name" = "acmebot-lloyds-gb-bink-com"
            "origins" = {"audit.lloyds.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_lloyds}}
        }

        # Retail Environment
        "uksouth_retail_api" = {
            "endpoint" = "uksouth-retail"
            "domain" = "api.retail.gb.bink.com"
            "cert_name" = "acmebot-retail-gb-bink-com"
            "origins" = {"api.retail.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_retail}}
        }
        "uksouth_retail_docs" = {
            "endpoint" = "uksouth-retail"
            "domain" = "docs.retail.gb.bink.com"
            "cert_name" = "acmebot-retail-gb-bink-com"
            "origins" = {"docs.retail.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_retail}}
        }
        "uksouth_retail_retailer" = {
            "endpoint" = "uksouth-retail"
            "domain" = "retailer.retail.gb.bink.com"
            "cert_name" = "acmebot-retail-gb-bink-com"
            "origins" = {"retailer.retail.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_retail}}
        }
        # Production Environment
        "uksouth_prod_stats" = {
            "endpoint" = "uksouth-prod"
            "domain" = "stats.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"stats.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_grafana" = {
            "endpoint" = "uksouth-prod"
            "domain" = "grafana.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"grafana.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_kratos" = {
            "endpoint" = "uksouth-prod"
            "domain" = "service-api.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"kratos.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_bpl" = {
            "endpoint" = "uksouth-prod"
            "domain" = "bpl.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"bpl.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_rewards" = {
            "endpoint" = "uksouth-prod"
            "domain" = "rewards.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"rewards.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_policies" = {
            "endpoint" = "uksouth-prod"
            "domain" = "policies.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"policies.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_tableau" = {
            "endpoint" = "uksouth-prod"
            "domain" = "tableau.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"tableau.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_airbyte" = {
            "endpoint" = "uksouth-prod"
            "domain" = "airbyte.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"airbyte.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_prefect" = {
            "endpoint" = "uksouth-prod"
            "domain" = "prefect.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"prefect.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_audit" = {
            "endpoint" = "uksouth-prod"
            "domain" = "audit.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"audit.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_asset_register" = {
            "endpoint" = "uksouth-prod"
            "domain" = "asset-register.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"asset-register.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_pypi" = {
            "endpoint" = "uksouth-prod"
            "domain" = "pypi.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"pypi.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_bridge" = {
            "endpoint" = "uksouth-prod"
            "domain" = "bridge.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"bridge.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_docs" = {
            "endpoint" = "uksouth-prod"
            "domain" = "docs.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"docs.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_api" = {
            "endpoint" = "uksouth-prod"
            "domain" = "api.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"api.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_portal" = {
            "endpoint" = "uksouth-prod"
            "domain" = "portal.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"portal.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }
        "uksouth_prod_retailer" = {
            "endpoint" = "uksouth-prod"
            "domain" = "retailer.gb.bink.com"
            "cert_name" = "acmebot-gb-bink-com"
            "origins" = {"retailer.prod.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod}}
        }

        # DEPRECATED: Endpoints to remove after 17th of Jan 2024
        "uksouth_sandbox_lloyds_sit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "lloyds-sit.sandbox.gb.bink.com"
            "cert_name" = "acmebot-sandbox-gb-bink-com"
            "origins" = {"api.lloyds.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_lloyds}}
        }
        "uksouth_sandbox_sit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "sit.sandbox.gb.bink.com"
            "cert_name" = "acmebot-sandbox-gb-bink-com"
            "origins" = {"api.lloyds.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_lloyds}}
        }
        "uksouth_sandbox_retail" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "retail.sandbox.gb.bink.com"
            "cert_name" = "acmebot-sandbox-gb-bink-com"
            "origins" = {"api.retail.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_retail}}
        }
    }

    endpoints = distinct([ for og in local.origin_groups : og.endpoint ])
    origins = merge(flatten(([
        for group_key, group_value in local.origin_groups : {
            for origin_key, origin_value in group_value.origins :
                "${group_key}-${origin_key}" => {
                    "domain" = origin_key,
                    "origin_group" = group_key,
                    "id" = origin_value.id,
                }
            }
    ]))...)

    kv_certs = toset([
        "acmebot-gb-bink-com",
        "acmebot-ait-gb-bink-com",
        "acmebot-dev-gb-bink-com",
        "acmebot-staging-gb-bink-com",
        "acmebot-sandbox-gb-bink-com",
        "acmebot-lloyds-gb-bink-com",
        "acmebot-retail-gb-bink-com",
        "acmebot-perf-gb-bink-com",
    ])
}

variable "common" {
    type = object({
        location = optional(string, "uksouth")
        loganalytics_id = string
        response_timeout_seconds = optional(number, 60)
        secure_origins = object({
            ipv4 = list(string)
            ipv6 = list(string)
            checkly = optional(list(string), ["167.172.61.234/32", "167.172.53.20/32"])
            tailscale = optional(list(string), [])
        })
        dns_zone = object({
            id = string
            name = string
            resource_group = string
        })
        tags = optional(map(string), {
            Environment = "Core"
            Role = "Front Door"
        })
        key_vault = object({
            sku_name = optional(string, "standard")
            cdn_object_id = optional(string, "602c4504-db34-4004-bd0a-dbdf556784dd")
            tf_object_id = optional(string, "4869640a-3727-4496-a8eb-f7fae0872410")
            admin_object_ids = optional(map(string), {})
            admin_ips = optional(list(string), [])
        })
    })
}

data "azurerm_client_config" "i" {}

resource "azurerm_resource_group" "i" {
    name = "${var.common.location}-frontdoor"
    location = var.common.location

    tags = var.common.tags
}

resource "azurerm_key_vault" "i" {
    name = "bink-${azurerm_resource_group.i.name}"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    sku_name = var.common.key_vault.sku_name
    tenant_id = data.azurerm_client_config.i.tenant_id
    public_network_access_enabled = true

    network_acls {
        default_action = "Deny"
        bypass = "AzureServices"
        ip_rules = concat(var.common.key_vault.admin_ips, local.acmebot_ips)
    }
}

resource "azurerm_key_vault_access_policy" "i" {
    for_each = merge(var.common.key_vault.admin_object_ids, {
        "terraform" = var.common.key_vault.tf_object_id
    })
    key_vault_id = azurerm_key_vault.i.id

    tenant_id = data.azurerm_client_config.i.tenant_id
    object_id = each.value

    certificate_permissions = [
        "Backup", "Create", "Delete", "DeleteIssuers", "Get",
        "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts",
        "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
    ]
    secret_permissions = [
        "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
}

resource "azurerm_key_vault_access_policy" "cdn" {
    key_vault_id = azurerm_key_vault.i.id

    tenant_id = data.azurerm_client_config.i.tenant_id
    object_id = var.common.key_vault.cdn_object_id

    secret_permissions = [ "Get" ]
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_key_vault.i.id
    log_analytics_workspace_id = var.common.loganalytics_id

    enabled_log { category = "AuditEvent" }
    enabled_log { category = "AzurePolicyEvaluationDetails" }
    metric {
        category = "AllMetrics"
        enabled = false
    }
}

data "azurerm_key_vault_certificate" "i" {
    for_each = local.kv_certs
    name = split(".", each.key)[0]
    key_vault_id = azurerm_key_vault.i.id
}

resource "azurerm_cdn_frontdoor_profile" "i" {
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    response_timeout_seconds = var.common.response_timeout_seconds
    sku_name = "Premium_AzureFrontDoor"

    tags = var.common.tags
}

resource "azurerm_monitor_diagnostic_setting" "afd" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_cdn_frontdoor_profile.i.id
    log_analytics_workspace_id = var.common.loganalytics_id

    enabled_log { category = "FrontDoorAccessLog" }
    enabled_log { category = "FrontDoorHealthProbeLog" }
    enabled_log { category = "FrontDoorWebApplicationFirewallLog" }
    metric {
        category = "AllMetrics"
        enabled = false
    }
}

# TODO: Figure out a use case for this and implement in a logical way
resource "azurerm_cdn_frontdoor_rule_set" "standard" {
    name = "standard"
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id
}

resource "azurerm_cdn_frontdoor_secret" "i" {
    for_each = data.azurerm_key_vault_certificate.i
    name = each.value.name
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

    secret {
        customer_certificate {
            key_vault_certificate_id = each.value.versionless_id
        }
    }
}

resource "azurerm_cdn_frontdoor_endpoint" "i" {
    for_each = toset(local.endpoints)
    name = each.key
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id
}

resource "azurerm_cdn_frontdoor_custom_domain" "i" {
    for_each = local.origin_groups
    name = replace(each.value.domain, ".", "-")
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id
    dns_zone_id = var.common.dns_zone.id
    host_name = each.value.domain

    tls {
        certificate_type = "CustomerCertificate"
        minimum_tls_version = "TLS12"
        cdn_frontdoor_secret_id = azurerm_cdn_frontdoor_secret.i[each.value.cert_name].id
    }
}

resource "azurerm_dns_cname_record" "i" {
    for_each = local.origin_groups
    name = trimsuffix(each.value.domain, ".bink.com")
    zone_name = var.common.dns_zone.name
    resource_group_name = var.common.dns_zone.resource_group
    ttl = 3600
    record = azurerm_cdn_frontdoor_endpoint.i[each.value.endpoint].host_name
}

resource "azurerm_cdn_frontdoor_origin_group" "i" {
    for_each = local.origin_groups
    name = replace(each.key, "_", "-")
    session_affinity_enabled = false
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

    load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "i" {
    for_each = local.origins
    name = replace(each.value.domain, ".", "-")
    cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.i[each.value.origin_group].id
    enabled = true

    certificate_name_check_enabled = true

    host_name = each.value.domain
    origin_host_header = each.value.domain
    priority = 1
    weight = 1
    private_link {
        request_message = "Request access for Private Link Origin CDN Frontdoor"
        location = var.common.location
        private_link_target_id = each.value.id
    }
}

resource "azurerm_cdn_frontdoor_route" "i" {
    for_each = local.origin_groups
    name = replace(each.key, "_", "-")
    cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.i[each.value.endpoint].id
    cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.i[each.key].id
    cdn_frontdoor_origin_ids = [
        for k, v in each.value.origins : azurerm_cdn_frontdoor_origin.i["${each.key}-${k}"].id
    ]
    cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.standard.id]
    enabled = true

    forwarding_protocol = "HttpsOnly"
    https_redirect_enabled = true
    patterns_to_match = ["/*"]
    supported_protocols = ["Http", "Https"]

    cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.i[each.key].id]
    link_to_default_domain = false
}

resource "azurerm_cdn_frontdoor_route" "cache" {
    for_each = { for key, value in local.origin_groups : key => value if can(value.cached_endpoints) }
    name = "${replace(each.key, "_", "-")}-cached"
    cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.i[each.value.endpoint].id
    cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.i[each.key].id
    cdn_frontdoor_origin_ids = [
        for k, v in each.value.origins : azurerm_cdn_frontdoor_origin.i["${each.key}-${k}"].id
    ]
    cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.standard.id]
    enabled = true

    forwarding_protocol = "HttpsOnly"
    https_redirect_enabled = true
    patterns_to_match = each.value.cached_endpoints
    supported_protocols = ["Http", "Https"]

    cache {
        query_string_caching_behavior = "UseQueryString"
        compression_enabled = false
    }

    cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.i[each.key].id]
    link_to_default_domain = false
}
