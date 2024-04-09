resource "azurerm_firewall_policy" "uksouth" {
  name                = "uksouth-${azurerm_resource_group.i.name}"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  base_policy_id      = azurerm_firewall_policy.i.id
  sku                 = "Basic"
}

resource "azurerm_firewall_policy_rule_collection_group" "uksouth_loyalty_schemes" {
  name               = "LoyatySchemes"
  firewall_policy_id = azurerm_firewall_policy.uksouth.id
  priority           = 100
  network_rule_collection {
    name     = "TGIFridays SFTP"
    action   = "Allow"
    priority = 1000
    rule {
      name                  = "SFTP"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_ports     = [22]
      destination_addresses = ["185.64.224.12"]
    }
  }
  application_rule_collection {
    name     = "Itsu"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["itsucomms.com", "api.pepperhq.com"]
    }
    rule {
      name = "UAT"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["atreemouat.itsucomms.com", "beta-api.pepperhq.com"]
    }
  }
  application_rule_collection {
    name     = "Atreemo"
    action   = "Allow"
    priority = 2010
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["rhianna.atreemo.uk", "binkwebhook.atreemo.uk"]
    }
  }
  application_rule_collection {
    name     = "Slim Chickens"
    action   = "Allow"
    priority = 2020
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.podifi.com", "pos.uk.eagleeye.com", "portal.uk.eagleeye.com"]
    }
    rule {
      name = "Demo"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["demoapi.podifi.com", "pos.sandbox.uk.eagleeye.com"]
    }
  }
  application_rule_collection {
    name     = "Squaremeal"
    action   = "Allow"
    priority = 2030
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["sm-uk.azure-api.net", "uk-bink-transactions.azurewebsites.net"]
    }
    rule {
      name = "Dev"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["uk-bink-transactions-dev.azurewebsites.net"]
    }
  }
  application_rule_collection {
    name     = "TGIFridays"
    action   = "Allow"
    priority = 2040
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dashboard.punchh.com", "mobileapi.punchh.com", "dashboard-api.punchh.com"]
    }
    rule {
      name = "Sandbox"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["sandbox.punchh.com"]
    }
  }
  application_rule_collection {
    name     = "ASOS"
    action   = "Allow"
    priority = 2050
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["api.jigsaw360.com"]
    }
    rule {
      name = "Dev"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dev.jigsaw360.com"]
    }
  }
  application_rule_collection {
    name     = "The Works"
    action   = "Allow"
    priority = 2060
    rule {
      name = "Production"
      protocols {
        type = "Https"
        port = 50104
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dc-uk1.givex.com", "dc-uk2.givex.com"]
    }
    rule {
      name = "Dev"
      protocols {
        type = "Https"
        port = 50104
      }
      source_addresses  = ["*"]
      destination_fqdns = ["dev-dataconnect.givex.com", "beta-dataconnect.givex.com"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "uksouth_freshservice" {
  name               = "FreshService"
  firewall_policy_id = azurerm_firewall_policy.uksouth.id
  priority           = 200
  application_rule_collection {
    name     = "FreshService"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Bink"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["bink.freshservice.com"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "uksouth_datawarehouse" {
  name               = "DataWarehouse"
  firewall_policy_id = azurerm_firewall_policy.uksouth.id
  priority           = 300
  application_rule_collection {
    name     = "Snowflake"
    action   = "Allow"
    priority = 2000
    rule {
      name = "Snowflake Production"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["xb90214.eu-west-2.aws.snowflakecomputing.com"]
    }
    rule {
      name = "Snowflake UAT"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["ee39463.eu-west-2.aws.snowflakecomputing.com"]
    }
    rule {
      name = "Snowflake Dev"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["ci34413.eu-west-2.aws.snowflakecomputing.com"]
    }
  }
  application_rule_collection {
    name     = "GetDBT"
    action   = "Allow"
    priority = 2010
    rule {
      name = "DBT"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["hub.getdbt.com"]
    }
  }
  application_rule_collection {
    name     = "Tableau"
    action   = "Allow"
    priority = 2020
    rule {
      name = "Telemetry"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["prod.telemetry.tableausoftware.com", "qa.telemetry.tableausoftware.com"]
    }
    rule {
      name = "License Server"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["atr.licensing.tableau.com"]
    }
    rule {
      name = "NGINX"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.nginx.org"] // Make rule more verbose
    }
    rule {
      name = "Postgres APT"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["apt.postgresql.org"]
    }
  }
}
