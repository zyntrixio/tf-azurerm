terraform {
  backend "azurerm" {
    storage_account_name = "binkitops"
    container_name = "terraform"
    key = "uksouth-firewall.tfstate"
  }
}
