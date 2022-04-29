terraform {
    required_providers {
        kubectl = {
            source  = "gavinbunney/kubectl"
            version = ">= 1.7.0"
        }
    }
}

resource "azurerm_resource_group" "i" {
    name = "uksouth-mimir"
    location = "UK South"
}

resource "azurerm_virtual_network" "i" {
    name = "mimir-vnet"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    address_space = [ var.cidr ]
}

resource "azurerm_subnet" "i" {
    name = "AzureKubernetesService"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    address_prefixes = [ var.cidr ]
}

resource "azurerm_route_table" "i" {
    name = "mimir-routes"
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    disable_bgp_route_propagation = true

    route {
        name = "default"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.peering.firewall_ip
    }
}

resource "azurerm_subnet_route_table_association" "i" {
    subnet_id = azurerm_subnet.i.id
    route_table_id = azurerm_route_table.i.id
}

resource "azurerm_virtual_network_peering" "local-to-fw" {
    name = "local-to-firewall"
    resource_group_name = azurerm_resource_group.i.name
    virtual_network_name = azurerm_virtual_network.i.name
    remote_virtual_network_id = var.peering.vnet_id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "fw-to-local" {
    name = "local-to-mimir"
    resource_group_name = var.peering.rg_name
    virtual_network_name = var.peering.vnet_name
    remote_virtual_network_id = azurerm_virtual_network.i.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_user_assigned_identity" "i" {
    resource_group_name = azurerm_resource_group.i.name
    location = azurerm_resource_group.i.location
    name = azurerm_resource_group.i.name
}

resource "azurerm_role_assignment" "i" {
    scope = azurerm_resource_group.i.id
    role_definition_name = "Contributor"
    principal_id = azurerm_user_assigned_identity.i.principal_id
}

resource "azurerm_kubernetes_cluster" "i" {
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
    automatic_channel_upgrade = var.automatic_channel_upgrade
    location = azurerm_resource_group.i.location
    node_resource_group = "${azurerm_resource_group.i.name}-nodes"
    dns_prefix = azurerm_resource_group.i.name
    sku_tier = var.sku_tier

    default_node_pool {
        name = "default"
        node_count = var.node_count
        vm_size = var.node_size
        vnet_subnet_id = azurerm_subnet.i.id
        max_pods = 100
    }

    network_profile {
        network_plugin = "azure"
        service_cidr = "172.16.0.0/16"
        dns_service_ip = "172.16.0.10"
        docker_bridge_cidr = "172.17.0.0/16"
        outbound_type = "userDefinedRouting"
        load_balancer_sku = "standard"
    }

    identity {
        type = "UserAssigned"
        identity_ids = [ azurerm_user_assigned_identity.i.id ]
    }

    linux_profile {
        admin_username = "laadmin"
        ssh_key {
            key_data = file("~/.ssh/id_bink_azure_terraform.pub")
        }
    }

    azure_active_directory_role_based_access_control {
        managed = true
        azure_rbac_enabled = true
        admin_group_object_ids = [ "aac28b59-8ac3-4443-bccc-3fb820165a08" ] # DevOps
    }

    maintenance_window {
        allowed {
            day = "Tuesday"
            hours = [0, 1, 2, 3, 4, 5, 6]
        }
    }
}

data "azurerm_kubernetes_cluster" "i" {
    depends_on = [ azurerm_kubernetes_cluster.i ]
    name = azurerm_resource_group.i.name
    resource_group_name = azurerm_resource_group.i.name
}

resource "azurerm_firewall_network_rule_collection" "i" {
    name = "aks_api_server-mimir"
    azure_firewall_name = var.peering.firewall_name
    resource_group_name = var.peering.rg_name
    priority = 2000
    action = "Allow"
    rule {
        name = "443/tcp"
        source_addresses = ["*"]
        destination_ports = ["443"]
        protocols = ["TCP"]
        destination_fqdns = [
            trimprefix(trimsuffix(data.azurerm_kubernetes_cluster.i.kube_config.0.host, ":443"), "https://")
        ]
    }
}

provider "kubectl" {
    host = data.azurerm_kubernetes_cluster.i.kube_admin_config.0.host
    client_certificate = base64decode(data.azurerm_kubernetes_cluster.i.kube_admin_config.0.client_certificate)
    client_key = base64decode(data.azurerm_kubernetes_cluster.i.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.i.kube_admin_config.0.cluster_ca_certificate)
}

resource "kubectl_manifest" "flux_namespace" {
    depends_on = [ data.azurerm_kubernetes_cluster.i ]
    yaml_body = file("${path.module}/flux/namespace.yaml")
    lifecycle {
        ignore_changes = [ yaml_incluster ]
    }
}

data "kubectl_file_documents" "flux_deploy" {
    content = file("${path.module}/flux/deploy.yaml")
}

resource "kubectl_manifest" "flux_deploy" {
    depends_on = [ kubectl_manifest.flux_namespace ]
    for_each = data.kubectl_file_documents.flux_deploy.manifests
    yaml_body = each.value
    wait_for_rollout = false
    lifecycle {
        ignore_changes = all
    }
}

data "kubectl_file_documents" "flux_sync" {
    content = file("${path.module}/flux/sync.yaml")
}

resource "kubectl_manifest" "flux_sync" {
    depends_on = [ kubectl_manifest.flux_deploy ]
    for_each = data.kubectl_file_documents.flux_sync.manifests
    yaml_body = each.value
    wait_for_rollout = false
    lifecycle {
        ignore_changes = all
    }
}

resource "kubectl_manifest" "flux_cluster_vars" {
    depends_on = [ kubectl_manifest.flux_deploy ]
    yaml_body = templatefile("${path.module}/flux/vars.yaml", {
        location = "uksouth",
        cluster_name = "mimir",
        loadbalancer_ip = cidrhost(var.cidr, 65534)
    })
}
