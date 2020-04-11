terraform {
  backend "azurerm" {
    storage_account_name = "binkitops"
    container_name = "terraform"
    key = "ukwest-monitoring.tfstate"
  }
}
