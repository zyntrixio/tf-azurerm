resource "azurerm_dns_zone" "trenette_co_uk" {
    name = "trenette.co.uk"
    resource_group_name = azurerm_resource_group.rg.name
}

locals {
    trenette_co_uk = {
        a_records = {}
        cname_records = {}
        mx_records = {}
        srv_records = {}
        txt_records = {}
    }
}
