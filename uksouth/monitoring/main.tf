resource "azurerm_resource_group" "rg" {
  name = "uksouth-monitoring"
  location = "uksouth"

  tags = var.tags
}
