resource "azurerm_resource_group" "rg" {
    name = "Default-ActivityLogAlerts"
    location = var.location

    tags = var.tags
}

resource "azurerm_monitor_action_group" "devops" {
    name = "devops-actiongroup"
    resource_group_name = azurerm_resource_group.rg.name
    short_name = "devops"

    webhook_receiver {
        name = "teams"
        service_uri = "https://outlook.office.com/webhook/bf220ac8-d509-474f-a568-148982784d19@a6e2367a-92ea-4e5a-b565-723830bcc095/IncomingWebhook/f025ce17fb50462399d599684b592261/48aca6b1-4d56-4a15-bc92-8aa9d97300df"
        use_common_alert_schema = true
    }
    email_receiver {
        name = "devops"
        email_address = "devops@bink.com"
        use_common_alert_schema = true
    }
}
