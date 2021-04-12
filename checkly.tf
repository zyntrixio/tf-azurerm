provider "checkly" {
    api_key = "dfde2548823240ebb9cfbefdf2811fac"
}

# Webhooks to be setup in future once provider supports Teams Alerts
# Production - https://hellobink.webhook.office.com/webhookb2/bf220ac8-d509-474f-a568-148982784d19@a6e2367a-92ea-4e5a-b565-723830bcc095/IncomingWebhook/a029cfdc8f4a49b2af9f08b7de391e91/48aca6b1-4d56-4a15-bc92-8aa9d97300df
# Staging - https://hellobink.webhook.office.com/webhookb2/bf220ac8-d509-474f-a568-148982784d19@a6e2367a-92ea-4e5a-b565-723830bcc095/IncomingWebhook/73a61077e5994a7d93ed76144b498f00/48aca6b1-4d56-4a15-bc92-8aa9d97300df
# Dev - https://hellobink.webhook.office.com/webhookb2/bf220ac8-d509-474f-a568-148982784d19@a6e2367a-92ea-4e5a-b565-723830bcc095/IncomingWebhook/09bd262a8ea143ee9138c36900e7d215/48aca6b1-4d56-4a15-bc92-8aa9d97300df

variable "checkly_groups" {
    default = {
        "prod-afd-bypass" = {
            name = "Production - Front Door Bypass",
            activated = true,
            muted = true
            tags = ["prod"]
            base_url = "https://api.prod0.uksouth.bink.sh:4000"
            auth_token = "Token eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJidW5kbGVfaWQiOiJjb20uYmluay53YWxsZXQiLCJ1c2VyX2lkIjoiZGV2b3BzQGJpbmsuY29tIiwic3ViIjoxMzgxNjIsImlhdCI6MTU5MTg2ODU2MX0.tqmHG_ajuXAk6MogbmWSYsr7qrlGBjVrcJdvnxPMTCM" # devops@bink.com
            alert_channel_id = 8509
        },
        "prod" = {
            name = "Production",
            activated = true,
            muted = false
            tags = ["prod"]
            base_url = "https://api.gb.bink.com"
            auth_token = "Token eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJidW5kbGVfaWQiOiJjb20uYmluay53YWxsZXQiLCJ1c2VyX2lkIjoiZGV2b3BzQGJpbmsuY29tIiwic3ViIjoxMzgxNjIsImlhdCI6MTU5MTg2ODU2MX0.tqmHG_ajuXAk6MogbmWSYsr7qrlGBjVrcJdvnxPMTCM" # devops@bink.com
            alert_channel_id = 8509
        },
        "staging" = {
            name = "Staging",
            activated = true,
            muted = true
            tags = ["staging"]
            base_url = "https://api.staging.gb.bink.com"
            auth_token = "Token eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJidW5kbGVfaWQiOiJjb20uYmluay53YWxsZXQiLCJ1c2VyX2lkIjoiY3ByZXNzbGFuZEBiaW5rLmNvbSIsInN1YiI6MTY0NSwiaWF0IjoxNjExOTQ1MDMyfQ.kSzpi_PbopD3Q6yrHqo0CQJRQmQ5DFfGXyQgjeWfCdk" # cpressland@bink.com
            alert_channel_id = 8510
        },
        "dev" = {
            name = "Development",
            activated = true,
            muted = true
            tags = ["dev"]
            base_url = "https://api.dev.gb.bink.com"
            auth_token = "Token eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJidW5kbGVfaWQiOiJjb20uYmluay53YWxsZXQiLCJ1c2VyX2lkIjoiY3ByZXNzbGFuZEBiaW5rLmNvbSIsInN1YiI6NTA0LCJpYXQiOjE2MTE5NDUwODd9.EfQ-m53UIxT2wCADycNRYsU-t5U6Gvek0IW3uSNFHn8" # cpressland@bink.com
            alert_channel_id = 8512
        },
    }
}

resource "checkly_check_group" "env" {
    for_each = var.checkly_groups
    name = each.value["name"]
    activated = each.value["activated"]
    muted = each.value["muted"]
    tags = each.value["tags"]
    concurrency = 1
    locations = [
        "eu-west-2"
    ]
    api_check_defaults {
        url = each.value["base_url"]
        headers = {
            Content-Type = "Content-Type",
            Authorization = each.value["auth_token"]
        }
        assertion {
            source = "STATUS_CODE"
            comparison = "EQUALS"
            target = "200"
        }
    }
    alert_settings {
        escalation_type = "RUN_BASED"
        run_based_escalation {
            failed_run_threshold = 2
        }
        ssl_certificates {
            enabled = false
            alert_threshold = 30
        }
        reminders {
            amount = 1
        }
        time_based_escalation {
            minutes_failing_threshold = 5
        }
    }
    double_check = true
    alert_channel_subscription {
        channel_id = each.value["alert_channel_id"]
        activated = true
    }
}

variable "checkly_checks" {
    default = {
        payment_cards = {
            name = "/payment_cards",
            url = "{{GROUP_BASE_URL}}/ubiquity/payment_cards",
        },
        membership_cards = {
            name = "/membership_cards",
            url = "{{GROUP_BASE_URL}}/ubiquity/membership_cards",
        },
        membership_plans = {
            name = "/membership_plans",
            url = "{{GROUP_BASE_URL}}/ubiquity/membership_plans",
        },
        healthz = {
            name = "/healthz",
            url = "{{GROUP_BASE_URL}}/healthz",
        }
    }
}

resource "checkly_check" "prod" {
    for_each = var.checkly_checks
    name = each.value["name"]
    type = "API"
    activated = true
    frequency = 1
    tags = ["dashboard"]
    locations = [
        "eu-west-2",
    ]
    degraded_response_time = 500
    max_response_time = 2000
    request {
        url = each.value["url"]
        follow_redirects = false
    }
    group_id = checkly_check_group.env["prod"].id
    lifecycle {
        ignore_changes = [group_order]
    }
}

resource "checkly_check" "prod-afd" {
    for_each = var.checkly_checks
    name = each.value["name"]
    type = "API"
    activated = true
    frequency = 1
    locations = [
        "eu-west-2",
    ]
    degraded_response_time = 500
    max_response_time = 2000
    request {
        url = each.value["url"]
        follow_redirects = false
    }
    group_id = checkly_check_group.env["prod-afd-bypass"].id
    lifecycle {
        ignore_changes = [group_order]
    }
}

resource "checkly_check" "staging" {
    for_each = var.checkly_checks
    name = each.value["name"]
    type = "API"
    activated = true
    frequency = 5
    tags = []
    locations = [
        "eu-west-2",
    ]
    degraded_response_time = 500
    max_response_time = 2000
    request {
        url = each.value["url"]
        follow_redirects = false
    }
    group_id = checkly_check_group.env["staging"].id
    lifecycle {
        ignore_changes = [group_order]
    }
}

resource "checkly_check" "dev" {
    for_each = var.checkly_checks
    name = each.value["name"]
    type = "API"
    activated = true
    frequency = 5
    tags = []
    locations = [
        "eu-west-2",
    ]
    degraded_response_time = 500
    max_response_time = 2000
    request {
        url = each.value["url"]
        follow_redirects = false
    }
    group_id = checkly_check_group.env["dev"].id
    lifecycle {
        ignore_changes = [group_order]
    }
}
