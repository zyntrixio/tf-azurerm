terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">= 3.49.0"
            configuration_aliases = [ azurerm.core ]
        }
    }
}

data "azurerm_client_config" "i" {}

resource "azurerm_resource_group" "i" {
    name = "${var.common.location}-${var.common.name}"
    location = var.common.location
}
