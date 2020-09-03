terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
        chef = {
            source = "terraform-providers/chef"
        }
        random = {
            source = "hashicorp/random"
        }
    }
    required_version = ">= 0.13"
}
