resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}

resource "azurerm_storage_account" "itops" {
    name = "binkitops"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
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
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkopsreportsdev" {
    name = "binkopsreportsdev"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkopsreportsstaging" {
    name = "binkopsreportsstaging"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkbackupsdev" {
    name = "binkbackupsdev"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkbackupsstaging" {
    name = "binkbackupsstaging"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkbackupspreprod" {
    name = "binkbackupspreprod"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "GRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkbackupsprod" {
    name = "binkbackupsprod"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "GRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "binkgitlabbackups" {
    name = "binkgitlabbackups"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "RAGRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "aphrodite" {
    name = "aphrodite"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westeurope"
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "GRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "aphroditestaging" {
    name = "aphroditestaging"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westeurope"
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
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "GRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_role_assignment" "bink_iam_sperrygrove" {
    scope = azurerm_storage_account.bink.id
    role_definition_name = "Contributor"
    principal_id = "c7c13573-de9a-443e-a1a7-cc272cb26e2e"
}

resource "azurerm_storage_account" "mids" {
    name = "mids"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "harmonia" {
    name = "harmonia"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "harmoniapreprod" {
    name = "harmoniapreprod"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_storage_account" "harmoniastaging" {
    name = "harmoniastaging"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_role_assignment" "harmoniastaging_iam_sperrygrove" {
    scope = azurerm_storage_account.harmoniastaging.id
    role_definition_name = "Contributor"
    principal_id = "c7c13573-de9a-443e-a1a7-cc272cb26e2e"
}

resource "azurerm_storage_account" "harmoniadev" {
    name = "harmoniadev"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_role_assignment" "harmoniadev_iam_sperrygrove" {
    scope = azurerm_storage_account.harmoniadev.id
    role_definition_name = "Contributor"
    principal_id = "c7c13573-de9a-443e-a1a7-cc272cb26e2e"
}

resource "azurerm_storage_account" "thoughtspot" {
    name = "thoughtspot"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westeurope"
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}

resource "azurerm_container_registry" "binkops" {
    name = "binkops"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westeurope"
    sku = "Premium"
    admin_enabled = true
    georeplication_locations = ["UK South", "UK West"]
}

resource "azurerm_container_registry" "olympus" {
    name = "olympus"
    resource_group_name = azurerm_resource_group.rg.name
    location = "westeurope"
    sku = "Premium"
    admin_enabled = true
    georeplication_locations = ["UK South", "UK West"]
}

resource "azurerm_storage_account" "stagingsftp" {
    name = "stagingsftp"
    resource_group_name = azurerm_resource_group.rg.name
    location = "uksouth"
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
}
