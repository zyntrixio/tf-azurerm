resource "azurerm_user_assigned_identity" "aks" {
    name = "${azurerm_resource_group.i.name}-aks"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_role_assignment" "aks" {
    scope = azurerm_virtual_network.i.id
    role_definition_name = "Network Contributor"
    principal_id = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "i" {
    count = var.kube.enabled ? 1 : 0

    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location

    automatic_channel_upgrade = var.kube.automatic_channel_upgrade
    node_resource_group = "${azurerm_resource_group.i.name}-nodes"
    dns_prefix = azurerm_resource_group.i.name
    sku_tier = var.kube.sku_tier
    azure_policy_enabled = false
    local_account_disabled = true

    # Waiting on before proceeding with Azure Prometheus:
    #   https://github.com/hashicorp/terraform-provider-azurerm/issues/18809
    #   https://github.com/hashicorp/terraform-provider-azurerm/issues/20702
    # monitor_metrics {}

    default_node_pool {
        name = "default"
        enable_auto_scaling = true
        min_count = var.kube.pool_min_count
        max_count = var.kube.pool_max_count
        vm_size = var.kube.pool_vm_size
        zones = var.kube.pool_zones
        os_disk_type = var.kube.pool_os_disk_type
        vnet_subnet_id = azurerm_subnet.kube_nodes.id
        max_pods = 100
    }

    api_server_access_profile {
        authorized_ip_ranges = var.kube.authorized_ip_ranges
        vnet_integration_enabled = true
        subnet_id = azurerm_subnet.kube_controller.id
    }

    network_profile {
        network_plugin = "azure"
        service_cidr = "172.16.0.0/16"
        dns_service_ip = "172.16.0.10"
        outbound_type = "userDefinedRouting"
        load_balancer_sku = "standard"
    }

    key_vault_secrets_provider {
        secret_rotation_enabled = false
    }

    identity {
        type = "UserAssigned"
        identity_ids = [ azurerm_user_assigned_identity.aks.id ]
    }

    auto_scaler_profile {
        skip_nodes_with_local_storage = false
    }

    azure_active_directory_role_based_access_control {
        managed = true
        azure_rbac_enabled = true
        admin_group_object_ids = var.kube.aad_admin_group_object_ids
    }

    maintenance_window {
        allowed {
            day = var.kube.maintenance_day
            hours = [0, 1, 2, 3, 4, 5, 6]
        }
    }
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
    count = var.kube.enabled && var.loganalytics.enabled ? 1 : 0

    name = "loganalytics"
    target_resource_id = azurerm_kubernetes_cluster.i[0].id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.i[0].id

    enabled_log { category = "kube-apiserver" }
    enabled_log { category = "kube-controller-manager" }
    enabled_log { category = "kube-scheduler" }
    metric {
        category = "AllMetrics"
        enabled = false
    }
}
