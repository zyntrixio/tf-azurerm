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

provider "azurerm" {
  alias           = "cp"
  subscription_id = "07e0d4b3-0b0c-438d-98ea-1d4c2367739b"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uksouth_development"
  subscription_id = "6a36a6fd-e97c-42f2-88ff-2484d8165f53"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uksouth_staging"
  subscription_id = "e28b2912-1f6d-4ac7-9cd7-443d73876e10"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uksouth_sandbox"
  subscription_id = "64678f82-1a1b-4096-b7e9-41b1bdcdc024"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "uksouth_production"
  subscription_id = "42706d13-8023-4b0c-b98a-1a562cb9ac40"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias           = "ukwest_disasterrecovery"
  subscription_id = "538100b6-70c7-4b23-b5fa-eb2de96115ea"
  client_id       = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret   = var.azurerm_terraform_client_id
  tenant_id       = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
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
