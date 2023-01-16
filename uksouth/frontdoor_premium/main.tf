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
        "uksouth_tools" = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-tools-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-tools"
        "uksouth_dev" = "/subscriptions/794aa787-ec6a-40dd-ba82-0ad64ed51639/resourceGroups/uksouth-dev-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-dev"
        "uksouth_staging" = "/subscriptions/457b0db5-6680-480f-9e77-2dafb06bd9dc/resourceGroups/uksouth-staging-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-staging"
        "uksouth_sandbox" = "/subscriptions/957523d8-bbe2-4f68-8fae-95975157e91c/resourceGroups/uksouth-sandbox-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-sandbox"
        "uksouth_prod0" = "/subscriptions/79560fde-5831-481d-8c3c-e812ef5046e5/resourceGroups/uksouth-prod0-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-prod0"
        "uksouth_prod1" = "/subscriptions/79560fde-5831-481d-8c3c-e812ef5046e5/resourceGroups/uksouth-prod1-nodes/providers/Microsoft.Network/privateLinkServices/uksouth-prod1"
    }

    origin_groups = {
        # Dev Environment
        "uksouth_dev_api" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "api.dev.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"api.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_bpl" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "bpl.dev.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"bpl.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_reflector" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "reflector.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"reflector.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_docs" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "docs.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"api2-docs.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_portal" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "portal.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"portal.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_wallet" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "wallet.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"web-bink.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }
        "uksouth_dev_wasabi" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "wasabi.dev.gb.bink.com"
            "cert_name" = "acmebot-dev-gb-bink-com"
            "origins" = {"web-wasabi.dev.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_dev}}
        }

        # Staging Envrionment
        "uksouth_staging_api" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "api.staging.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"api.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_bpl" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "bpl.staging.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"bpl.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_reflector" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "reflector.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"reflector.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_policies" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "policies.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"policies.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_help" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "help.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"help.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_docs" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "docs.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"api2-docs.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_link" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "link.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"link.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_portal" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "portal.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"portal.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_wallet" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "wallet.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            "origins" = {"web-bink.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }
        "uksouth_staging_wasabi" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "wasabi.staging.gb.bink.com"
            "cert_name" = "acmebot-staging-gb-bink-com"
            # "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"web-wasabi.staging.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_staging}}
        }

        # Sandbox Environment
        "uksouth_sandbox_barclays_sit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "barclays-sit.sandbox.gb.bink.com"
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"barclays-sit.sandbox.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_sandbox}}
        }
        "uksouth_sandbox_barclays_oat" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "barclays-oat.sandbox.gb.bink.com"
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"barclays-oat.sandbox.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_sandbox}}
        }
        "uksouth_sandbox_lloyds_sit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "lloyds-sit.sandbox.gb.bink.com"
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"lloyds-sit.sandbox.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_sandbox}}
        }
        "uksouth_sandbox_docs" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "docs.sandbox.gb.bink.com"
            "cert_name" = "acmebot-sandbox-gb-bink-com"
            "origins" = {"api2-docs.sandbox.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_sandbox}}
        }
        # This should be removed in future once Kish confirms lloyds have moved to lloyds-sit.sandbox.gb.bink.com
        "uksouth_sandbox_sit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "sit.sandbox.gb.bink.com"
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"lloyds-sit.sandbox.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_sandbox}}
        }
        "uksouth_sandbox_retail" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "retail.sandbox.gb.bink.com"
            "cert_name" = "acmebot-sandbox-gb-bink-com"
            "origins" = {"retail.sandbox.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_sandbox}}
        }

        # Production Environment
        "uksouth_prod_kratos" = {
            "endpoint" = "uksouth-prod"
            "domain" = "service-api.gb.bink.com"
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "kratos.prod0.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod0}
                "kratos.prod1.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod1}
            }
        }
        "uksouth_prod_link" = {
            "endpoint" = "uksouth-prod"
            "domain" = "link.gb.bink.com"
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "link.prod0.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod0}
                "link.prod1.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod1}
            }
        }
        "uksouth_prod_help" = {
            "endpoint" = "uksouth-prod"
            "domain" = "help.gb.bink.com"
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "help.prod0.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod0}
                "help.prod1.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod1}
            }
        }
        "uksouth_prod_bpl" = {
            "endpoint" = "uksouth-prod"
            "domain" = "bpl.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "bpl.prod0.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod0}
                "bpl.prod1.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod1}
            }
        }
        "uksouth_prod_policies" = {
            "endpoint" = "uksouth-prod"
            "domain" = "policies.gb.bink.com"
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "policies.prod0.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod0}
                "policies.prod1.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod1}
            }
        }
        "uksouth_prod_api" = {
            "endpoint" = "uksouth-prod"
            "domain" = "api.gb.bink.com"
            "cached_endpoints" = ["/content/*"]
            "cert_name" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "api.prod0.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod0}
                "api.prod1.uksouth.bink.sh" = {"id" = local.private_link_ids.uksouth_prod1}
            }
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

    kv_certs = setunion(
        fileset("${path.module}/certificates", "*.pfx"),
        toset([
            "acmebot-dev-gb-bink-com",
            "acmebot-staging-gb-bink-com",
            "acmebot-sandbox-gb-bink-com",
        ])
    )
}

variable "common" {
    type = object({
        location = optional(string, "uksouth")
        loganalytics_id = string
        response_timeout_seconds = optional(number, 16)
        secure_origins = object({
            ipv4 = list(string)
            ipv6 = list(string)
            checkly = optional(list(string), ["167.172.61.234/32", "167.172.53.20/32"])
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

resource "azurerm_key_vault_certificate" "i" {
    for_each = fileset("${path.module}/certificates", "*.pfx")

    name = split(".", each.key)[0]
    key_vault_id = azurerm_key_vault.i.id

    certificate {
        contents = filebase64("${path.module}/certificates/${each.key}")
        password = ""
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

    # The below was added to mitigate downtime assocaited with key_vault_certificate_id
    # changing from each.value.id to each.value.versionless_id
    # during the next scheduled downtime window we'll execute this as I've no idea
    # what the API behaviour will be
    lifecycle {
        ignore_changes = all
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

resource "azurerm_dns_txt_record" "i" {
    for_each = local.origin_groups
    name = "_dnsauth.${trimsuffix(each.value.domain, ".bink.com")}"
    zone_name = var.common.dns_zone.name
    resource_group_name = var.common.dns_zone.resource_group
    ttl = 3600

    record {
        value = azurerm_cdn_frontdoor_custom_domain.i[each.key].validation_token
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

    health_probe {
        protocol = "Https"
        interval_in_seconds = 120
        request_type = "HEAD"
        path = "/healthz"
    }

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
