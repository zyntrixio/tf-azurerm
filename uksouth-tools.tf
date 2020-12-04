module "uksouth_tools_environment" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_environment.git?ref=1.3.0"
    providers = {
        azurerm = azurerm
    }
    resource_group_name = "uksouth-tools"
    location = "uksouth"
    tags = {
        "Environment" = "Core",
    }

    storage_config = {
        common = {
            name = "binkuksouthtools",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }
}

module "uksouth_tools_cluster_0" {
    source = "git::ssh://git@git.bink.com/Terraform/azurerm_cluster.git?ref=1.3.0"
    providers = {
        azurerm = azurerm
        azurerm.core = azurerm
    }

    resource_group_name = "uksouth-tools-k0"
    cluster_name = "tools0"
    location = "uksouth"
    vnet_cidr = "10.33.0.0/16"
    eventhub_authid = "/subscriptions/0add5c8e-50a6-4821-be0f-7a47c879b009/resourceGroups/uksouth-eventhubs/providers/Microsoft.EventHub/namespaces/binkuksouthlogs/authorizationRules/RootManageSharedAccessKey"
    bifrost_version = "4.6.0"
    ubuntu_version = "20.04"

    controller_vm_size = "Standard_D2s_v4"
    worker_vm_size = "Standard_D4s_v4"
    worker_scaleset_size = 1
    use_scaleset = true

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

    tags = {
        "Environment" = "Core",
    }
}
