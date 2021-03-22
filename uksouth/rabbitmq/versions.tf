terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
        chef = {
            source = "terrycain/chef"
        }
    }
    required_version = ">= 0.13"
}
