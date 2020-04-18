resource "azurerm_resource_group" "rg" {
  name = "uksouth-bastion"
  location = "uksouth"

  tags = var.tags
}
