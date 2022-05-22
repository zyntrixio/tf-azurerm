resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}

resource "azurerm_storage_account" "itops" {
    name = "binkitops"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    cross_tenant_replication_enabled = false
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "GRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkopsreports" {
    name = "binkopsreports"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    cross_tenant_replication_enabled = false
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "bink" {
    name = "bink"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westeurope"

    cross_tenant_replication_enabled = false
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "GRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkpublic" {
    name = "binkpublic"
    resource_group_name = azurerm_resource_group.rg.name
    location = "uksouth"

    cross_tenant_replication_enabled = false
    account_tier = "Standard"
    account_replication_type = "ZRS"
    enable_https_traffic_only = true
    allow_nested_items_to_be_public = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkarchives" {
    name = "binkarchives"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    cross_tenant_replication_enabled = false
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "mids" {
    name = "mids"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    cross_tenant_replication_enabled = false
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkpypi" {
    name = "binkpypi"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    cross_tenant_replication_enabled = false
    account_tier = "Standard"
    account_replication_type = "ZRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_container_registry" "binkops" {
    name = "binkops"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westeurope"
    sku = "Premium"
    admin_enabled = true
    georeplications {
        location = "uksouth"
    }
    georeplications {
        location = "ukwest"
    }
}

resource "azurerm_container_registry" "olympus" {
    name = "olympus"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westeurope"
    sku = "Premium"
    admin_enabled = true
    georeplications {
        location = "uksouth"
    }
    georeplications {
        location = "ukwest"
    }
}

resource "azurerm_storage_account" "binkmimir" {
    name = "binkmimir"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    cross_tenant_replication_enabled = false
    account_kind = "StorageV2"
    account_tier = "Standard"
    account_replication_type = "ZRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}
