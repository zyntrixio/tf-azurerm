resource "azurerm_resource_group" "rg" {
    name = "uksouth-eventhubs"
    location = "uksouth"
}

resource "azurerm_storage_account" "binkuksouthlogs" {
    name = "binkuksouthlogs"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_eventhub_namespace" "binkuksouthlogs" {
    name = "binkuksouthlogs"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
    capacity = 1
    zone_redundant = true
}

# Couldnt add auth rules in TF due to: https://github.com/terraform-providers/terraform-provider-azurerm/issues/7310


resource "azurerm_eventhub" "azurefrontdoor" {
    name = "azurefrontdoor"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}

resource "azurerm_eventhub" "azurefrontdoorpre" {
    name = "azurefrontdoorpre"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1

    lifecycle {
        ignore_changes = [partition_count, partition_ids]
    }
}

resource "azurerm_eventhub" "azurefirewall" {
    name = "azurefirewall"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}

resource "azurerm_eventhub" "azureactivedirectory" {
    name = "azureactivedirectory"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}

resource "azurerm_eventhub" "azurepostgres" {
    name = "azurepostgres"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}

resource "azurerm_eventhub" "azurensg" {
    name = "azurensg"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}

resource "azurerm_eventhub" "azurekeyvault" {
    name = "azurekeyvault"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}

resource "azurerm_eventhub" "defenderatp" {
    name = "defenderatp"
    namespace_name = azurerm_eventhub_namespace.binkuksouthlogs.name
    resource_group_name = azurerm_resource_group.rg.name
    partition_count = 2
    message_retention = 1
}
