provider "azurerm" {
  version = "~> 1.30.1"
  subscription_id = "0add5c8e-50a6-4821-be0f-7a47c879b009"
  client_id = "98e2ee67-a52d-40fc-9b39-155887530a7b"
  tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
}

resource "azurerm_resource_group" "rg" {
  name = "uksouth-vault"
  location = "uksouth"

  tags = {
    environment = "production"
  }
}
