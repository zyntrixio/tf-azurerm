resource "random_string" "ac" {
    length = 4
    upper = false
    special = false
    min_numeric = 2
}

resource "azurerm_app_configuration" "i" {
    name = "${azurerm_resource_group.i.name}-${random_string.ac.result}"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    sku = "standard"
}

resource "azurerm_role_assignment" "ac_iam_ro" {
    for_each = {
        for k, v in var.iam : k => v
             if contains(v["assigned_to"], "ac_ro")
    }

    scope = azurerm_app_configuration.i.id
    role_definition_name = "Reader"
    principal_id = each.key
}

resource "azurerm_role_assignment" "ac_iam_rw" {
    for_each = {
        for k, v in var.iam : k => v
             if contains(v["assigned_to"], "ac_su") ||
                contains(v["assigned_to"], "ac_rw")
    }

    scope = azurerm_app_configuration.i.id
    role_definition_name = "Contributor"
    principal_id = each.key
}
