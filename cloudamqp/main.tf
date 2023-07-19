terraform {
    required_providers {
        cloudamqp = {
            source = "cloudamqp/cloudamqp"
        }
    }
}

variable "region" {
    type = string
    default = "azure-arm::uksouth"
}

variable "subnet" {type = string}

resource "cloudamqp_vpc" "i" {
    name = "azure-${reverse(split(":", var.region))[0]}"
    region = var.region
    subnet = var.subnet
}

output "vpc" {
    value = {
        id = cloudamqp_vpc.i.id,
        name = cloudamqp_vpc.i.vpc_name,
        subnet = var.subnet
    }
}
