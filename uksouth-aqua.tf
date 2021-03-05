module "uksouth_aqua_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=1.6.0"
    providers = {
        azurerm = azurerm
    }
    resource_group_name = "uksouth-aqua"
    location = "uksouth"
    tags = {
        "Environment" = "Core",
    }

    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    storage_config = {
        common = {
            name = "binkuksouthaqua",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
    cert_manager_zone_id = module.uksouth-dns.bink-sh[2]
}

module "uksouth_aqua_cluster_0" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=2.1.0"
    providers = {
        azurerm = azurerm
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-aqua-k0"
    cluster_name = "aqua0"
    location = "uksouth"
    vnet_cidr = "10.5.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    bifrost_version = "4.6.3"
    ubuntu_version = "20.04"

    controller_vm_size = "Standard_D2s_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_count = 2

    prometheus_subnet = "10.33.0.0/18"

    # Gitops repo, Managed identity for syncing common secrets
    gitops_repo = "git@git.bink.com:GitOps/uksouth-aqua.git"
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
        ingress_priority = 1000
        rule_priority = 1000
        public_ip = module.uksouth-firewall.public_ips.12.ip_address
        secure_origins = local.secure_origins
        developer_ips = local.developer_ips
        ingress_source = "*"
        ingress_http = 80
        ingress_https = 443
        ingress_controller = 6000
    }

    tcp_endpoint = true
    additional_firewall_rules = [
        {
            name = "aqua-grpc"
            source_addresses = ["10.169.0.0/18"]
            destination_ports = ["30002"]
            destination_addresses = [cidrhost(cidrsubnet("10.5.0.0/16", 2, 0), 4)]
            protocols = ["TCP"]
        },
        {
            name = "gitlab-scanner"
            source_addresses = ["192.168.10.5/32"]
            destination_ports = ["30001"]
            destination_addresses = [cidrhost(cidrsubnet("10.5.0.0/16", 2, 0), 4)]
            protocols = ["TCP"]
        }
    ]

    postgres_servers = module.uksouth_aqua_environment.postgres_servers

    tags = {
        "Environment" = "Core",
    }
}
