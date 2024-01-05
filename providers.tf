variable "azurerm_terraform_client_id" {}

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
  alias = "cp"
  subscription_id = "07e0d4b3-0b0c-438d-98ea-1d4c2367739b"
  client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret = var.azurerm_terraform_client_id
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias = "uksouth_development"
  subscription_id = "6a36a6fd-e97c-42f2-88ff-2484d8165f53"
  client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret = var.azurerm_terraform_client_id
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias = "uksouth_staging"
  subscription_id = "e28b2912-1f6d-4ac7-9cd7-443d73876e10"
  client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret = var.azurerm_terraform_client_id
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias = "uksouth_ait"
  subscription_id = "0b92124d-e5fe-4c9a-a898-1fdf02502e01"
  client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret = var.azurerm_terraform_client_id
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias = "uksouth_sandbox"
  subscription_id = "64678f82-1a1b-4096-b7e9-41b1bdcdc024"
  client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret = var.azurerm_terraform_client_id
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias = "uksouth_performance"
  subscription_id = "c49c2fde-9e7d-41c6-ac61-f85f9fa51416"
  client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret = var.azurerm_terraform_client_id
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias = "uksouth_production"
  subscription_id = "42706d13-8023-4b0c-b98a-1a562cb9ac40"
  client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret = var.azurerm_terraform_client_id
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "azurerm" {
  alias = "ukwest_disasterrecovery"
  subscription_id = "538100b6-70c7-4b23-b5fa-eb2de96115ea"
  client_id = "204e5c70-3a77-4ba3-9714-af93352db62a"
  client_secret = var.azurerm_terraform_client_id
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
  features {}
}

provider "cloudamqp" {
    apikey = "09929459-8feb-476d-8831-d36daf691713"
    enable_faster_instance_destroy = true
}

provider "nextdns" {
    api_key = "d2af762e854b3499bf7eda52fb01d1b51700f02c"
}

provider "random" {}
