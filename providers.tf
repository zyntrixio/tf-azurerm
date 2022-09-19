variable "azurerm_terraform_client_id" {}

provider "azurerm" {
  subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uk_core"
  subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uk_production"
  subscription_id = "79560fde-5831-481d-8c3c-e812ef5046e5"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uk_preprod"
  subscription_id = "6e685cd8-73f6-4aa6-857c-04ed9b21d17d"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uk_staging"
  subscription_id = "457b0db5-6680-480f-9e77-2dafb06bd9dc"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uk_dev"
  subscription_id = "794aa787-ec6a-40dd-ba82-0ad64ed51639"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uk_sandbox"
  subscription_id = "957523d8-bbe2-4f68-8fae-95975157e91c"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "chef" {
  server_url = "https://chef.uksouth.bink.sh/organizations/bink/"

  client_name  = chomp(file("~/.chef/username"))
  key_material = file("~/.chef/user.pem")
}

provider "random" {}

resource "azurerm_role_assignment" "devops" {
  for_each = local.subscriptions

  scope                = "/subscriptions/${each.value["id"]}"
  role_definition_name = "Owner"
  principal_id         = local.aad_group.devops
}

resource "azurerm_role_assignment" "qa" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = local.aad_group.qa
}

resource "azurerm_role_assignment" "jo_raine" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Billing Reader"
  principal_id         = local.aad_user.jo_raine
}

resource "azurerm_role_assignment" "azure_frontdoor" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = "f0222751-c786-45ca-bbfb-66037b63c4ac"
}

resource "azurerm_role_assignment" "architecture" {
  for_each = local.subscriptions

  scope                = "/subscriptions/${each.value["id"]}"
  role_definition_name = "Reader"
  principal_id         = local.aad_group.architecture
}
