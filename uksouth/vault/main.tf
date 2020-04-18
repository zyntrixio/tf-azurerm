resource "azurerm_resource_group" "rg" {
  name = "uksouth-vault"
  location = "uksouth"

  tags = {
    environment = "production"
  }
}
