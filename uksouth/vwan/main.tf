## This has all been commented out, frankly, Azure Virtual WAN is... bad

## Many features of Azure Virtual WAN are not yet available in Terraform
## https://github.com/terraform-providers/terraform-provider-azurerm/issues/3279
## This should be updated as more features become available and relevant Web UI
## configured resources should be imported into the Terraform State.


resource "azurerm_resource_group" "rg" {
    name = "uksouth-vwan"
    location = "uksouth"

    tags = var.tags
}

# resource "azurerm_virtual_wan" "bink" {
#   name = "bink-vwan"
#   resource_group_name = azurerm_resource_group.rg.name
#   location = azurerm_resource_group.rg.location
# }

# resource "azurerm_virtual_hub" "uksouth" {
#     name = "uksouth"
#     resource_group_name = azurerm_resource_group.rg.name
#     location = azurerm_resource_group.rg.location
#     virtual_wan_id = azurerm_virtual_wan.bink.id
#     address_prefix = var.uk_hub_ip_range
# }

# resource "azurerm_vpn_gateway" "uksouth" {
#     name = "uksouth"
#     resource_group_name = azurerm_resource_group.rg.name
#     location = azurerm_resource_group.rg.location
#     virtual_hub_id = azurerm_virtual_hub.uksouth.id
#     scale_unit = 1
# }

# resource "azurerm_vpn_server_configuration" "uksouth" {
#     name = "uksouth"
#     resource_group_name = azurerm_resource_group.rg.name
#     location = azurerm_resource_group.rg.location
#     vpn_protocols = [ "IkeV2" ]
#     vpn_authentication_types = [ "Certificate" ]

#     client_root_certificate {
#         name = "Bink VPN CA"
#         public_cert_data = "MIIE8DCCAtigAwIBAgIIHKaCMPGZUTUwDQYJKoZIhvcNAQEMBQAwFjEUMBIGA1UEAxMLQmluayBWUE4gQ0EwHhcNMjAwNjA3MTQ0NTA4WhcNMjMwNjA3MTQ0NTA4WjAWMRQwEgYDVQQDEwtCaW5rIFZQTiBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALjGGtxmIZnp1hMi8qBpaMOPJ5hXn/0JqloLast29Vqnc3HU7KxkxGsXS+c8qiPCK5RlgQhCzCaumzS0cPCMIwQZzddvvakvNJg1VVKg48ipsmzRHDYXKpWRbKoD2pjRWZ8oKYsui4rQ56LqTGFQDI5b37NuHP1kQv2QNLlt2zTal5ifMIdwmuwgndcf5IOqjtBjtoGLC2RAR7oInbXD8QosL7cxv/ODoUHFihUAsmwO2MasLe9PjyQKQUcgM3WXKqhc2guvV8+CbAkVb1QTCfol3W6Md2SXDEAwqFfgbr/MvNho0VhkEI3VvPsFEV0PfbQQjHJtAos0xsSd/wjErMvdEFvDOCBM6bfLtmGbMeJ7yyNwa1iRN07y/OZyPHrjCwi1gIid3SbvxlfsE3MxqLmNR/9yh52vJwVZ9MaaH/LPnLNdtbGN0RN9HXctgujYgLaNp1/ZQI4KsWsNriFSmZh2fGedI9/SOumICmYRDdx2m2Ax+Tl0xsjC4zbAPiiKBnj9uE9Djcp8Ypc01XeSjCl4SC119yKraDAYaucr6o0JeTi+z4kmpJPNoYBZIc+cvZHOCzE+9P62yGFBx+hRl+vtpGsrkaAz+nF7ODQlVa98mHlcebMFXw/q2kzkHk+zdxcE22mkB6z/AEauZo7Ef79nefB81XxCaC2go2Ox9iuTAgMBAAGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBR3+TBG3AGnVaJ878Q3kEBtywvbkjANBgkqhkiG9w0BAQwFAAOCAgEAjGPPpXz7p6yc60F7vG2UyzZDS3knDkmmj3vbsAjLoRAFsQwlDXGhnJezIe1ICdfDIhPUwVdCK511t9yCBhKYblallFkLCxDJyUTsET8rlcmXdXt5WRLNJV/k+sJ/jCuIvPJipauAgUhWTYBRyzfizIsXwYa/TAaKkikmWQrABiPTtCfniNzaQl0C7Y4jPITyHtvmSPh09xEACTiZqhq2FtD51bUHrgGcb5aqwVdrFwQy9BnE3ASB+DXrH3vhly94yRqBi+hCDx5qisbAPd5eMPHImBLHwXYtLLL8e/+ITgX23qFUZeVXsQsaF+6//JGPlnaWDPO3RVPyBgUXvASYrgvYPZWxLdclqz1NE4ylI5aXLE/1DFHKi6ND3AXMooYHJRFrJn4SEmC4iQWeRroWYDVolcc4DbfskykYzH1xxfcXg0t2fpIFW+0FcL9DKn9Qfmf5skvJH1/PLqzwaAeu93nrA0rV18Ua9lneiXuVbo8GJ6F2BLUGXb0/Ys13xcCfs1WPTsn0vcm54JxIoHve6t/8R4SWqbC/L9DN8LKThDdck86QU60FddCg61YSAf3BMHGjWVIk0hNOzryoSkS86NbIbtcDusMX6bMabnx0UHGUaBRCNFvO3V4w6DZHtcZ7VckrpJnlArbY6DckAdKkkiNoodReuPiyNr91/tTZNVA="
#     }
# }

# resource "azurerm_point_to_site_vpn_gateway" "uksouth" {
#     name = "uksouth"
#     resource_group_name = azurerm_resource_group.rg.name
#     location = azurerm_resource_group.rg.location
#     virtual_hub_id = azurerm_virtual_hub.uksouth.id
#     vpn_server_configuration_id = azurerm_vpn_server_configuration.uksouth.id
#     scale_unit = 1
#     connection_configuration  {
#         name = "config"
#         vpn_client_address_pool  {
#             address_prefixes = [ var.uk_p2s_ip_range ]
#         }
#     }
# }

# resource "azurerm_virtual_hub_connection" "uksouth-firewall" {
#     name = "uksouth-firewall"
#     virtual_hub_id = azurerm_virtual_hub.uksouth.id
#     remote_virtual_network_id = var.firewall_vnet_id
#     hub_to_vitual_network_traffic_allowed = true
#     vitual_network_to_hub_gateways_traffic_allowed = true
#     internet_security_enabled = false
# }

# resource "azurerm_virtual_hub_connection" "uksouth-dev" {
#     name = "uksouth-dev"
#     virtual_hub_id = azurerm_virtual_hub.uksouth.id
#     remote_virtual_network_id = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-dev/providers/Microsoft.Network/virtualNetworks/dev-vnet"
#     hub_to_vitual_network_traffic_allowed = true
#     vitual_network_to_hub_gateways_traffic_allowed = true
#     internet_security_enabled = false
# }