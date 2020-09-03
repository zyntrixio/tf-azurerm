terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
        chef = {
            source = "terraform-providers/chef"
        }
    }
    required_version = ">= 0.13"
}
