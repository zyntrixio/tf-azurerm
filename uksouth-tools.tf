module "uksouth_tools_environment" {
    source = "github.com/binkhq/tf-azurerm_environment?ref=5.18.9"
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

resource "azurerm_user_assigned_identity" "prometheus" {
  name = "prometheus"
  resource_group_name = "uksouth-tools"
  location = "uksouth"
}

resource "azurerm_role_definition" "prometheus_azure_vm_read" {
  name  = "prometheus_vm_read"
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
  scope              = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.prometheus_azure_vm_read.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.prometheus.principal_id
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

  scope              = each.value
  role_definition_id = azurerm_role_definition.prometheus_azure_vm_read.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.prometheus.principal_id

  lifecycle {
    ignore_changes = [role_definition_id]
  }
}

resource "azurerm_role_definition" "service_tags_reader" {
    name  = "service_tags_reader"
    scope = data.azurerm_subscription.current.id

    permissions {
        actions = [
            "Microsoft.Network/locations/serviceTagDetails/read"
        ]
        not_actions = []
    }

    assignable_scopes = [
        data.azurerm_subscription.current.id,
    ]
}

resource "azurerm_role_assignment" "service_tags_reader" {
    scope = data.azurerm_subscription.current.id
    role_definition_id = azurerm_role_definition.service_tags_reader.role_definition_resource_id
    principal_id = "3f8a04a0-2675-48c5-a0df-7d3e0d684e79"  # App Registration: Azure Frontdoor IP Range Updater
}
