module "uksouth_tools_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=1.7.3"
    providers = {
        azurerm = azurerm
    }
    resource_group_name = "uksouth-tools"
    location = "uksouth"
    tags = {
        "Environment" = "Core",
    }

    keyvault_users = {
        Confluence = { object_id = "ce918d9f-5641-4798-b1d5-bf31d234921a" },
    }

    postgres_config = {
        common = {
            name = "bink-uksouth-tools-common",
            sku_name = "GP_Gen5_2",
            storage_gb = 500,
            public_access = false,
            databases = ["*"]
        },
    }

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    storage_config = {
        common = {
            name = "binkuksouthtools",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
    cert_manager_zone_id = module.uksouth-dns.bink-sh[2]
}

module "uksouth_tools_cluster_0" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=2.3.0"
    providers = {
        azurerm = azurerm
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-tools-k0"
    cluster_name = "tools0"
    location = "uksouth"
    vnet_cidr = "10.33.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    bifrost_version = "4.6.3"
    ubuntu_version = "20.04"

    controller_vm_size = "Standard_D2s_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_scaleset_size = 3
    use_scaleset = true

    prometheus_subnet = "10.33.0.0/18"

    # Gitops repo, Managed identity for syncing common secrets
    gitops_repo = "git@git.bink.com:GitOps/uksouth-tools.git"
    common_keyvault = data.terraform_remote_state.uksouth-common.outputs.keyvault
    common_keyvault_sync_identity = data.terraform_remote_state.uksouth-common.outputs.keyvault2kube_identity

    # DNS zones
    private_dns = module.uksouth-dns.private_dns
    public_dns = module.uksouth-dns.public_dns

    # Peers    
    peers = {
        firewall = {
            vnet_id = module.uksouth-firewall.vnet_id
            vnet_name = module.uksouth-firewall.vnet_name
            resource_group_name = module.uksouth-firewall.resource_group_name
        }
        elasticsearch = {
            vnet_id = module.uksouth-elasticsearch.vnet_id
            vnet_name = module.uksouth-elasticsearch.vnet_name
            resource_group_name = module.uksouth-elasticsearch.resource_group_name
        }
    }

    firewall = {
        firewall_name = module.uksouth-firewall.firewall_name
        resource_group_name = module.uksouth-firewall.resource_group_name
        ingress_priority = 1200
        rule_priority = 1200
        public_ip = module.uksouth-firewall.public_ips.5.ip_address
        secure_origins = local.secure_origins
        developer_ips = local.developer_ips
        ingress_source = "*"
        ingress_http = 80
        ingress_https = 443
        ingress_controller = 6000
    }

    tcp_endpoint = true
    additional_firewall_rules = [
        {  # Every node should listen with node-exporter on 9100
            name = "prometheus-to-node-exporter"
            source_addresses = ["10.33.0.0/18"]
            destination_ports = ["9100"]
            destination_addresses = ["10.0.0.0/8", "192.168.0.0/16"]
            protocols = ["TCP"]
        },
        {  # Scrape remote wireguard-exporter and node-exporter 
            name = "prometheus-to-wireguard"
            source_addresses = ["10.33.0.0/18"]
            destination_ports = ["9100", "9586"]
            destination_addresses = ["20.49.163.188/32"]
            protocols = ["TCP"]
        },
        {  # The kube api servers could appear in random /16's within 10.0.0.0/8 on 6443
            name = "prometheus-to-kube-api"
            source_addresses = ["10.33.0.0/18"]
            destination_ports = ["6443"]
            destination_addresses = ["10.0.0.0/8"]
            protocols = ["TCP"]
        },
        {  # Various things needs to hit tools on HTTPS (sadly is on 30001 now on the loadbalancer)
            name = "internal-to-toolshttps"
            source_addresses = ["10.0.0.0/8"]
            destination_ports = ["30001"]
            destination_addresses = ["10.33.0.0/18"]
            protocols = ["TCP"]
        },
    ]

    postgres_servers = module.uksouth_tools_environment.postgres_servers
    private_links = module.uksouth_tools_environment.private_links

    tags = {
        "Environment" = "Core",
    }
}

# Imported from the tools module
resource "azurerm_storage_account" "tools" {
    name = "binktools"
    resource_group_name = "uksouth-tools"
    location = "uksouth"

    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    min_tls_version = "TLS1_2"

    tags = {
        "Environment" = "Core",
    }
}

# CBA to figure out the import
# resource "azurerm_storage_container" "pypi" {
#     name = "pypi"
#     storage_account_name = azurerm_storage_account.tools.name
#     container_access_type = "private"
# }

# resource "azurerm_key_vault_access_policy" "confluence-macro" {
#     key_vault_id = module.kv.keyvault.id

#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = "ce918d9f-5641-4798-b1d5-bf31d234921a"

#     secret_permissions = [
#         "get",
#         "list",
#         "set",
#     ]
# }

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azurerm_user_assigned_identity" "prometheus" {
    resource_group_name = "uksouth-tools"
    location = "uksouth"

    name = "prometheus"
}

resource "azurerm_role_definition" "prometheus_azure_vm_read" {
    name = "prometheus_vm_read"
    scope = data.azurerm_subscription.current.id

    permissions {
        actions = [
            "Microsoft.Compute/virtualMachines/read",
            "Microsoft.Network/networkInterfaces/read",
            "Microsoft.Compute/virtualMachineScaleSets/read",
            "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read",
            "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces/read",
            "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces/ipConfigurations/read",
            "Microsoft.Compute/virtualMachineScaleSets/networkInterfaces/read",
        ]
        not_actions = []
    }

    assignable_scopes = [
        data.azurerm_subscription.current.id,
        "/subscriptions/79560fde-5831-481d-8c3c-e812ef5046e5",
        "/subscriptions/6e685cd8-73f6-4aa6-857c-04ed9b21d17d",
        "/subscriptions/457b0db5-6680-480f-9e77-2dafb06bd9dc",
        "/subscriptions/794aa787-ec6a-40dd-ba82-0ad64ed51639",
        "/subscriptions/957523d8-bbe2-4f68-8fae-95975157e91c"
    ]
}

resource "azurerm_role_assignment" "prometheus_azure_vm_read" {
    scope = data.azurerm_subscription.current.id
    role_definition_id = azurerm_role_definition.prometheus_azure_vm_read.role_definition_resource_id
    principal_id = azurerm_user_assigned_identity.prometheus.principal_id
}

locals {
    subs = toset([
        "/subscriptions/79560fde-5831-481d-8c3c-e812ef5046e5",
        "/subscriptions/6e685cd8-73f6-4aa6-857c-04ed9b21d17d",
        "/subscriptions/457b0db5-6680-480f-9e77-2dafb06bd9dc",
        "/subscriptions/794aa787-ec6a-40dd-ba82-0ad64ed51639",
        "/subscriptions/957523d8-bbe2-4f68-8fae-95975157e91c"
    ])
}

resource "azurerm_role_assignment" "prometheus_azure_vm_read_subs" {
    for_each = local.subs

    scope = each.value
    role_definition_id = azurerm_role_definition.prometheus_azure_vm_read.role_definition_resource_id
    principal_id = azurerm_user_assigned_identity.prometheus.principal_id

    lifecycle {
        ignore_changes = [role_definition_id]
    }
}
