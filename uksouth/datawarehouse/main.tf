terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.78.0"
    }
  }
}

resource "azurerm_resource_group" "i" {
  name     = "uksouth-datawarehouse"
  location = "uksouth"
}

resource "azurerm_storage_account" "i" {
    name = "binkuksouthdatalake"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    account_tier = "Standard"
    account_replication_type = "ZRS"
    account_kind = "StorageV2"
    is_hns_enabled = "true"
}

resource "azurerm_role_assignment" "susanne" {
  scope = azurerm_storage_account.i.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = "1813380e-e0e3-4963-8668-2d538c20481f"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "i" {
    name = "binkuksouthdatalake"
    storage_account_id = azurerm_storage_account.i.id
}

resource "random_pet" "i" {
    length = 1
}

resource "random_password" "i" {
    length = 24
    special = false
}

resource "azurerm_synapse_workspace" "i" {
    name = "binkuksouthsynapse"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.i.id
    sql_administrator_login = random_pet.i.id
    sql_administrator_login_password = random_password.i.result

    managed_virtual_network_enabled = true
    sql_identity_control_enabled = true
    managed_resource_group_name = "${azurerm_resource_group.i.name}-managed"

    aad_admin {
        login = "AzureAD Admin"
        object_id = var.sql_admin
        tenant_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"
    }
}

resource "azurerm_synapse_sql_pool" "i" {
    name = "binkuksouthsynapsepool"
    synapse_workspace_id = azurerm_synapse_workspace.i.id
    sku_name = "DW100c"
    create_mode = "Default"
    data_encrypted = true
}

resource "azurerm_synapse_firewall_rule" "ascot" {
    name = "Ascot"
    synapse_workspace_id = azurerm_synapse_workspace.i.id
    start_ip_address = "194.74.152.11"
    end_ip_address = "194.74.152.11"
}

resource "azurerm_synapse_firewall_rule" "wireguard" {
    name = "wireguard"
    synapse_workspace_id = azurerm_synapse_workspace.i.id
    start_ip_address = "20.49.163.188"
    end_ip_address = "20.49.163.188"
}

resource "azurerm_synapse_firewall_rule" "cp_home" {
    name = "cp_home"
    synapse_workspace_id = azurerm_synapse_workspace.i.id
    start_ip_address = "217.169.3.233"
    end_ip_address = "217.169.3.233"
}

resource "azurerm_synapse_role_assignment" "devops_admin" {
    synapse_workspace_id = azurerm_synapse_workspace.i.id
    role_name = "Synapse Administrator"
    principal_id = "a6e2367a-92ea-4e5a-b565-723830bcc095"  # DevOps
}
