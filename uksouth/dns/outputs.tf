output "dns_zones" {
    value = {
        resource_group = {
            name = azurerm_resource_group.rg.name
            id = azurerm_resource_group.rg.id
        }
        bink_host = {
            root = azurerm_private_dns_zone.uksouth_bink_host["root"]
            core = azurerm_private_dns_zone.uksouth_bink_host["core"]
            dev = azurerm_private_dns_zone.uksouth_bink_host["dev"]
            staging = azurerm_private_dns_zone.uksouth_bink_host["staging"]
            sandbox = azurerm_private_dns_zone.uksouth_bink_host["sandbox"]
            prod = azurerm_private_dns_zone.uksouth_bink_host["prod"]
            public = azurerm_dns_zone.bink-host
        }
        bink_sh = {
            root = azurerm_dns_zone.bink-sh
        }
        bink_com = {
            root = azurerm_dns_zone.bink-com
        }
    }
}
