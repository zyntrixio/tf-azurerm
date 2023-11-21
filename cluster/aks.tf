locals {
    aks_mi_readers = {
        for k, v in local.identities : k => v
            if var.kube.enabled && contains(v["assigned_to"], "aks_ro")
    }
    aks_mi_writers = {
        for k, v in local.identities : k => v
            if var.kube.enabled && contains(v["assigned_to"], "aks_rw")
    }
    aks_mi_admins = {
        for k, v in local.identities : k => v
            if var.kube.enabled && contains(v["assigned_to"], "aks_su")
    }
    aks_readers = {
        for k, v in var.iam : k => v
            if var.kube.enabled && contains(v["assigned_to"], "aks_ro")
    }
    aks_writers = {
        for k, v in var.iam : k => v
            if var.kube.enabled && contains(v["assigned_to"], "aks_rw")
    }
    aks_admins = {
        for k, v in var.iam : k => v
            if var.kube.enabled && contains(v["assigned_to"], "aks_su")
    }
    aks_users = merge(local.aks_readers, local.aks_writers, local.aks_admins)
}

resource "azurerm_user_assigned_identity" "aks" {
    name = "${azurerm_resource_group.i.name}-aks"
    location = azurerm_resource_group.i.location
    resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_role_assignment" "aks_vnet" {
    scope = azurerm_virtual_network.i.id
    role_definition_name = "Network Contributor"
    principal_id = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "aks_rt" {
    scope = azurerm_route_table.i.id
    role_definition_name = "Network Contributor"
    principal_id = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "i" {
    count = var.kube.enabled ? 1 : 0

    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location

    automatic_channel_upgrade = var.kube.automatic_channel_upgrade
    node_os_channel_upgrade = var.kube.node_os_channel_upgrade
    node_resource_group = "${azurerm_resource_group.i.name}-nodes"
    dns_prefix = azurerm_resource_group.i.name
    sku_tier = var.kube.sku_tier
    azure_policy_enabled = false
    oidc_issuer_enabled = true
    workload_identity_enabled = true
    local_account_disabled = true

    dynamic oms_agent {
        for_each = var.loganalytics.enabled ? [1] : []
        content {
            log_analytics_workspace_id = try(azurerm_log_analytics_workspace.i[0].id, "")
        }
    }

    key_vault_secrets_provider {
        secret_rotation_enabled = true
    }

    # Waiting on before proceeding with Azure Prometheus:
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
        os_disk_size_gb = var.kube.pool_os_disk_size_gb
        os_sku = var.kube.pool_os_sku
        vnet_subnet_id = azurerm_subnet.kube_nodes.id
        temporary_name_for_rotation = "temp"
        max_pods = 250
    }

    api_server_access_profile {
        authorized_ip_ranges = var.allowed_hosts.ipv4
        vnet_integration_enabled = true
        subnet_id = azurerm_subnet.kube_controller.id
    }

    network_profile {
        network_plugin = "azure"
        network_plugin_mode = "overlay"
        ebpf_data_plane = "cilium"
        service_cidr = "172.16.0.0/16"
        pod_cidr = "172.20.0.0/14"
        dns_service_ip = "172.16.0.10"
        outbound_type = "userDefinedRouting"
        load_balancer_sku = "standard"
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

    storage_profile {
        blob_driver_enabled = true
    }

    maintenance_window {
        allowed {
            day = var.kube.maintenance_day
            hours = [0, 1, 2, 3, 4, 5, 6]
        }
    }

    depends_on = [
        azurerm_subnet_route_table_association.kube_nodes,
        azurerm_virtual_network_peering.local,
        azurerm_virtual_network_peering.remote,
    ]

    lifecycle {
        ignore_changes = [
            monitor_metrics # This can be removed once #20702 is released.
        ]
    }
}

resource "azurerm_kubernetes_cluster_node_pool" "i" {
    for_each = var.kube.additional_node_pools

    name = each.key
    kubernetes_cluster_id = azurerm_kubernetes_cluster.i[0].id
    vm_size = each.value.vm_size
    node_count = each.value.node_count
    node_labels = each.value.node_labels
    node_taints = each.value.node_taints
    os_sku = each.value.os_sku
    os_disk_size_gb = each.value.os_disk_size_gb
    os_disk_type = each.value.os_disk_type
    zones = each.value.zones
    vnet_subnet_id = azurerm_subnet.kube_nodes.id

    priority = each.value.priority
    spot_max_price = each.value.spot_max_price

    enable_auto_scaling = each.value.enable_auto_scaling
    max_count = each.value.max_count
    min_count = each.value.min_count
    max_pods = 250

    lifecycle {
        ignore_changes = [ eviction_policy ]
    }
}

resource "azurerm_role_assignment" "aks_mi_ro" {
    for_each = local.aks_mi_readers

    scope = azurerm_kubernetes_cluster.i[0].id
    role_definition_name = "Azure Kubernetes Service RBAC Reader"
    principal_id = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "aks-acr" {
    scope = var.acr.id
    role_definition_name = "AcrPull"
    principal_id = azurerm_kubernetes_cluster.i[0].kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "flux-acr" {
    scope = var.acr.id
    role_definition_name = "AcrPull"
    principal_id = azurerm_user_assigned_identity.i["image-reflector-controller"].principal_id
}

resource "azurerm_role_assignment" "aks_mi_rw" {
    for_each = local.aks_mi_writers

    scope = azurerm_kubernetes_cluster.i[0].id
    role_definition_name = "Azure Kubernetes Service RBAC Writer"
    principal_id = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "aks_mi_su" {
    for_each = local.aks_mi_admins

    scope = azurerm_kubernetes_cluster.i[0].id
    role_definition_name = "Azure Kubernetes Service RBAC Admin"
    principal_id = azurerm_user_assigned_identity.i[each.key].principal_id
}

resource "azurerm_role_assignment" "aks_iam" {
    for_each = local.aks_users

    scope = azurerm_kubernetes_cluster.i[0].id
    role_definition_name = "Azure Kubernetes Service Cluster User Role"
    principal_id = each.key
}

resource "azurerm_role_assignment" "aks_iam_nodes" {
    for_each = local.aks_users

    scope = azurerm_kubernetes_cluster.i[0].node_resource_group_id
    role_definition_name = "Reader"
    principal_id = each.key
    depends_on = [ azurerm_kubernetes_cluster.i ]
}

resource "azurerm_role_assignment" "aks_iam_ro" {
    for_each = local.aks_readers

    scope = azurerm_kubernetes_cluster.i[0].id
    role_definition_name = "Azure Kubernetes Service RBAC Reader"
    principal_id = each.key
}

resource "azurerm_role_assignment" "aks_iam_rw" {
    for_each = local.aks_writers

    scope = azurerm_kubernetes_cluster.i[0].id
    role_definition_name = "Azure Kubernetes Service RBAC Writer"
    principal_id = each.key
}

resource "azurerm_role_assignment" "aks_iam_su" {
    for_each = local.aks_admins

    scope = azurerm_kubernetes_cluster.i[0].id
    role_definition_name = "Azure Kubernetes Service RBAC Admin"
    principal_id = each.key
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

resource "null_resource" "flux_install" {
    count = var.kube.enabled && var.keyvault.enabled && var.kube.flux_enabled ? 1 : 0
    provisioner "local-exec" {
        command = <<-EOF
            export CLUSTER_NAME="${var.common.name}"
            export CLUSTER_LOCATION="${azurerm_resource_group.i.location}"
            export CLUSTER_API_HOST="https://${azurerm_kubernetes_cluster.i[0].fqdn}:443"
            export CLUSTER_LB_IP="${cidrhost(cidrsubnet(var.common.cidr, 1, 0), 32766)}"
            export CLUSTER_PLS_IP="${cidrhost(cidrsubnet(var.common.cidr, 1, 0), 32765)}"
            export ENVIRONMENT_KEYVAULT=${azurerm_key_vault.i[0].vault_uri}
            export IDENTITY_KV_TO_KUBE=${azurerm_user_assigned_identity.i["kv-to-kube"].client_id}
            export KEYVAULT_KV_TO_KUBE=${try(azurerm_key_vault.i[0].name, "")}
            export IDENTITY_FLUX=${azurerm_user_assigned_identity.i["image-reflector-controller"].client_id}

            envsubst < ${path.module}/aks_templates/gotk-sync.yaml > /tmp/${azurerm_resource_group.i.name}.yaml

            az account set --subscription ${data.azurerm_subscription.i.subscription_id}

            az aks get-credentials --overwrite-existing \
                --resource-group ${azurerm_resource_group.i.name} \
                --name ${azurerm_resource_group.i.name}

            kubelogin convert-kubeconfig -l azurecli

            kubectl apply -f ${path.module}/aks_templates/container-azm-ms-agentconfig.yaml
            kubectl apply -f ${path.module}/aks_templates/gotk-components.yaml
            kubectl apply -f /tmp/${azurerm_resource_group.i.name}.yaml
        EOF
        interpreter = ["/bin/zsh", "-c"]
    }
}
