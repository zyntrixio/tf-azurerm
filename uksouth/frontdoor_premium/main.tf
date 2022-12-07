terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
    }
    required_version = ">= 1.3.3"
}

locals {
    origin_groups = {

        # Dev Environment
        "uksouth_dev_api" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "api.dev.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"api.dev.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_dev_bpl" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "bpl.dev.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"bpl.dev.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_dev_reflector" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "reflector.dev.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"reflector.dev.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_dev_docs" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "docs.dev.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"api2-docs.dev.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_dev_portal" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "portal.dev.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"portal.dev.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_dev_wallet" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "wallet.dev.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"web-bink.dev.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_dev_wasabi" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "wasabi.dev.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"web-wasabi.dev.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }

        # Staging Envrionment
        "uksouth_staging_api" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "api.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"api.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_bpl" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "bpl.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"bpl.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_reflector" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "reflector.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"reflector.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_policies" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "policies.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"policies.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_help" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "help.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"help.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_docs" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "docs.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"api2-docs.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_link" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "link.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"link.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_portal" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "portal.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"portal.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_wallet" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "wallet.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"web-bink.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_staging_wasabi" = {
            "endpoint" = "uksouth-nonprod"
            "domain" = "wasabi.staging.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"web-wasabi.staging.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }

        # Sandbox Environment
        "uksouth_sandbox_barclays_sit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "barclays-sit.sandbox.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"barclays-sit.sandbox.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_sandbox_barclays_oat" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "barclays-oat.sandbox.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"barclays-oat.sandbox.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_sandbox_lloyds_sit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "lloyds-sit.sandbox.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"lloyds-sit.sandbox.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        "uksouth_sandbox_docs" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "docs.sandbox.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"api2-docs.sandbox.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }
        # This should be removed in future once Kish confirms lloyds have moved to lloyds-sit.sandbox.gb.bink.com
        "uksouth_sandbox_sit" = {
            "endpoint" = "uksouth-sandbox"
            "domain" = "sit.sandbox.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {"lloyds-sit.sandbox.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}}
        }

        # Production Environment
        "uksouth_prod_kratos" = {
            "endpoint" = "uksouth-prod"
            "domain" = "service-api.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "kratos.prod0.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}
                "kratos.prod1.uksouth.bink.sh" = {"http_port" = 8001, "https_port" = 4001}
            }
        }
        "uksouth_prod_link" = {
            "endpoint" = "uksouth-prod"
            "domain" = "link.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "link.prod0.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}
                "link.prod1.uksouth.bink.sh" = {"http_port" = 8001, "https_port" = 4001}
            }
        }
        "uksouth_prod_help" = {
            "endpoint" = "uksouth-prod"
            "domain" = "help.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "help.prod0.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}
                "help.prod1.uksouth.bink.sh" = {"http_port" = 8001, "https_port" = 4001}
            }
        }
        "uksouth_prod_bpl" = {
            "endpoint" = "uksouth-prod"
            "domain" = "bpl.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "bpl.prod0.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}
                "bpl.prod1.uksouth.bink.sh" = {"http_port" = 8001, "https_port" = 4001}
            }
        }
        "uksouth_prod_policies" = {
            "endpoint" = "uksouth-prod"
            "domain" = "policies.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "policies.prod0.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}
                "policies.prod1.uksouth.bink.sh" = {"http_port" = 8001, "https_port" = 4001}
            }
        }
        "uksouth_prod_api" = {
            "endpoint" = "uksouth-prod"
            "domain" = "api.gb.bink.com"
            "secret_file" = "env-gb-bink-com-2022-2023.pfx"
            "origins" = {
                "api.prod0.uksouth.bink.sh" = {"http_port" = 8000, "https_port" = 4000}
                "api.prod1.uksouth.bink.sh" = {"http_port" = 8001, "https_port" = 4001}
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
                    "http_port" = origin_value.http_port,
                    "https_port" = origin_value.https_port,
                }
            }
        ]))...)
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
            tenant_id = optional(string, "a6e2367a-92ea-4e5a-b565-723830bcc095")
            cdn_object_id = optional(string, "602c4504-db34-4004-bd0a-dbdf556784dd")
            tf_object_id = optional(string, "4869640a-3727-4496-a8eb-f7fae0872410")
            admin_object_ids = optional(map(string), {})
            admin_ips = optional(list(string), [])
        })
    })
}

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
    tenant_id = var.common.key_vault.tenant_id
    public_network_access_enabled = true

    network_acls {
        default_action = "Deny"
        bypass = "AzureServices"
        ip_rules = var.common.key_vault.admin_ips
    }

    access_policy {
        tenant_id = var.common.key_vault.tenant_id
        object_id = var.common.key_vault.cdn_object_id

        secret_permissions = [ "Get" ]
    }

    dynamic access_policy {
        for_each = merge(var.common.key_vault.admin_object_ids, {
            "terraform" = var.common.key_vault.tf_object_id
        })
        content {
            tenant_id = var.common.key_vault.tenant_id
            object_id = access_policy.value

            certificate_permissions = [
                "Backup", "Create", "Delete", "DeleteIssuers", "Get",
                "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts",
                "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
            ]
            secret_permissions = [
                "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
            ]
        }
    }
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
    name = "binkuksouthlogs"
    target_resource_id = azurerm_key_vault.i.id
    log_analytics_workspace_id = var.common.loganalytics_id

    log {
        category = "AuditEvent"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "AzurePolicyEvaluationDetails"
        enabled = true
        retention_policy {
            days = 90
            enabled = false
        }
    }
    metric {
        category = "AllMetrics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
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

    log {
        category = "FrontDoorAccessLog"
        enabled = true
        retention_policy {
            days = 90
            enabled = true
        }
    }
    log {
        category = "FrontDoorHealthProbeLog"
        enabled = true
        retention_policy {
            days = 90
            enabled = false
        }
    }
    log {
        category = "FrontDoorWebApplicationFirewallLog"
        enabled = true
        retention_policy {
            days = 90
            enabled = false
        }
    }
    metric {
        category = "AllMetrics"
        enabled = false
        retention_policy {
            days = 0
            enabled = false
        }
    }
}

# TODO: Figure out a use case for this and implement in a logical way
resource "azurerm_cdn_frontdoor_rule_set" "standard" {
    name = "standard"
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id
}

resource "azurerm_cdn_frontdoor_secret" "i" {
    for_each = azurerm_key_vault_certificate.i
    name = each.value.name
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.i.id

    secret {
        customer_certificate {
            key_vault_certificate_id = each.value.id
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
        cdn_frontdoor_secret_id = azurerm_cdn_frontdoor_secret.i[each.value.secret_file].id
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
    http_port = each.value.http_port
    https_port = each.value.https_port
    origin_host_header = each.value.domain
    priority = 1
    weight = 1
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

    forwarding_protocol    = "HttpsOnly"
    https_redirect_enabled = true
    patterns_to_match      = ["/*"]
    supported_protocols    = ["Http", "Https"]

    cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.i[each.key].id]
    link_to_default_domain = false
}
