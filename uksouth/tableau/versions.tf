terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
        chef = {
            source = "terrycain/chef"
        }
        random = {
            source = "hashicorp/random"
        }
    }
    required_version = ">= 0.13"
}
