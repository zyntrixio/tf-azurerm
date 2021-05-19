variable azurerm_terraform_client_id {}

provider "azurerm" {
    subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
    client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
    client_secret = var.azurerm_terraform_client_id
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "azurerm" {
    alias = "uk_core"
    subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
    client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
    client_secret = var.azurerm_terraform_client_id
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "azurerm" {
    alias = "uk_production"
    subscription_id = "79560fde-5831-481d-8c3c-e812ef5046e5"
    client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
    client_secret = var.azurerm_terraform_client_id
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "azurerm" {
    alias = "uk_preprod"
    subscription_id = "6e685cd8-73f6-4aa6-857c-04ed9b21d17d"
    client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
    client_secret = var.azurerm_terraform_client_id
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "azurerm" {
    alias = "uk_staging"
    subscription_id = "457b0db5-6680-480f-9e77-2dafb06bd9dc"
    client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
    client_secret = var.azurerm_terraform_client_id
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "azurerm" {
    alias = "uk_dev"
    subscription_id = "794aa787-ec6a-40dd-ba82-0ad64ed51639"
    client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
    client_secret = var.azurerm_terraform_client_id
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "azurerm" {
    alias = "uk_sandbox"
    subscription_id = "957523d8-bbe2-4f68-8fae-95975157e91c"
    client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
    client_secret = var.azurerm_terraform_client_id
    tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    features {}
}

provider "chef" {
    server_url = "https://chef.uksouth.bink.sh:4444/organizations/bink/"

    client_name = chomp(file("~/.chef/username"))
    key_material = file("~/.chef/user.pem")
}

provider "random" {}

resource "azurerm_role_assignment" "devops" {
    for_each = local.subscriptions

    scope = "/subscriptions/${each.value["id"]}"
    role_definition_name = "Owner"
    principal_id = "aac28b59-8ac3-4443-bccc-3fb820165a08"
}

resource "azurerm_role_assignment" "devsecops" {
    for_each = local.subscriptions

    scope = "/subscriptions/${each.value["id"]}"
    role_definition_name = "Reader"
    principal_id = "13e033e8-4bfe-4bef-b41e-1344690c8373"
}

resource "azurerm_role_assignment" "confluence-macro" {
    for_each = local.subscriptions

    scope = "/subscriptions/${each.value["id"]}"
    role_definition_name = "Reader"
    principal_id = "ce918d9f-5641-4798-b1d5-bf31d234921a"
}

resource "azurerm_role_assignment" "backend" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Reader"
    principal_id = "219194f6-b186-4146-9be7-34b731e19001"
}

resource "azurerm_role_assignment" "qa" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Reader"
    principal_id = "2e3dc1d0-e6b8-4ceb-b1ae-d7ce15e2150d"
}

resource "azurerm_role_assignment" "architecture" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Reader"
    principal_id = "fb26c586-72a5-4fbc-b2b0-e1c28ef4fce1"
}

resource "azurerm_role_assignment" "jo_raine" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Billing Reader"
    principal_id = "ac4c9b34-2e1b-4e46-bfca-2d64e1a3adbc"
}

resource "azurerm_role_assignment" "kubernetes_sso" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Contributor"
    principal_id = "ed09bbbc-7b4d-4f2e-a657-3f0c7b3335c7"
}

resource "azurerm_role_assignment" "azure_frontdoor" {
    scope = data.azurerm_subscription.primary.id
    role_definition_name = "Contributor"
    principal_id = "f0222751-c786-45ca-bbfb-66037b63c4ac"
}

