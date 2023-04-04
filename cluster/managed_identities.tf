resource "azurerm_user_assigned_identity" "i" {
    for_each = var.managed_identities

    name = "${azurerm_resource_group.i.name}-${each.key}"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
}
