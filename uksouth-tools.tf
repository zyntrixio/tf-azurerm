module "uksouth_tools_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.19.0"
    providers = {
        azurerm = azurerm
        azurerm.core = azurerm
    }
    resource_group_name = "uksouth-tools"
    location = "uksouth"
    tags = {
        "Environment" = "Core",
    }

    vnet_cidr = "192.168.100.0/24"

    loganalytics_id = module.uksouth_loganalytics.id

    keyvault_users = {}

    postgres_flexible_config = {
        common = {
            name = "bink-uksouth-tools"
            version = "13"
            sku_name = "GP_Standard_D2ds_v4"
            storage_mb = 131072
            high_availability = false
            databases = [
                "asset_register",
                "mobsf",
                "postgres",
                "rss2teams",
            ]
        }
    }

    storage_config = {
        common = {
            name = "binkuksouthtools",
            account_replication_type = "ZRS",
            account_tier = "Standard"
        },
    }

    bink_sh_zone_id = module.uksouth-dns.dns_zones.bink_sh.root.id
    bink_host_zone_id = module.uksouth-dns.dns_zones.bink_host.public.id

    managed_identities = local.managed_identities

    aks = {
        tools = merge(local.aks_config_defaults, {
            name = "tools"
            api_ip_ranges = concat(local.secure_origins, [module.uksouth_firewall.public_ip_prefix])
            cidr = local.cidrs.uksouth.aks.tools
            dns = local.aks_dns.core_defaults
            iam = {}
            firewall = merge(local.aks_firewall_defaults, {
                rule_priority = 1600
                ingress = {
                    public_ip = module.uksouth_firewall.public_ips.14.ip_address
                    source_ip_groups = null
                    source_addr = ["*"]
                    http_port = 80
                    https_port = 443
                }
            })
            aad_admin_group_object_ids = [ "aac28b59-8ac3-4443-bccc-3fb820165a08" ] # DevOps
        })
    }
}

# Imported from the tools module
resource "azurerm_storage_account" "tools" {
  name                = "binktools"
  resource_group_name = "uksouth-tools"
  location            = "uksouth"

  cross_tenant_replication_enabled = false
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = {
    "Environment" = "Core",
  }
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
