resource "azuread_application" "hermes_uksouth_dev" {
    name = "Hermes - UKSouth - Development"
    reply_urls = ["http://localhost:8000/oidc/callback/"]
    type = "webapp/api"

    app_role {
        allowed_member_types = ["User"]
        description = "Read only users"
        display_name = "Read Only"
        is_enabled = true
        value = "readonly"
    }

    app_role {
        allowed_member_types = ["User"]
        description = "Read write users"
        display_name = "Read / Write"
        is_enabled = true
        value = "readwrite"
    }

    app_role {
        allowed_member_types = ["User"]
        description = "Superusers"
        display_name = "Superuser"
        is_enabled = true
        value = "superuser"
    }

    # No clue what this is, came along with the import
    required_resource_access {
        resource_app_id = "00000003-0000-0000-c000-000000000000"
        resource_access {
            id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
            type = "Scope"
        }
    }
}

resource "azuread_service_principal" "hermes_uksouth_dev" {
    application_id = azuread_application.hermes_uksouth_dev.application_id
    app_role_assignment_required = true

    tags = ["example", "tags", "here"]
}
