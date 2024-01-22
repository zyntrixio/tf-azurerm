resource "azurerm_resource_group" "rg" {
  name     = "uksouth-dns"
  location = "uksouth"

  tags = var.tags
}
