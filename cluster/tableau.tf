resource "azurerm_network_security_group" "tableau" {
  count = var.tableau.enabled ? 1 : 0

  name                = "${azurerm_resource_group.i.name}-tableau"
  location            = azurerm_resource_group.i.location
  resource_group_name = azurerm_resource_group.i.name

  security_rule {
    name                       = "BlockEverything"
    description                = "Default Block All Rule"
    access                     = "Deny"
    priority                   = 4096
    direction                  = "Inbound"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  dynamic "security_rule" {
    for_each = {
      "Allow_TCP_22"   = { "priority" : "100", "port" : "22", "source" : azurerm_subnet.kube_nodes.address_prefixes[0] },
      "Allow_TCP_80"   = { "priority" : "200", "port" : "80", "source" : azurerm_subnet.kube_nodes.address_prefixes[0] },
      "Allow_TCP_8850" = { "priority" : "210", "port" : "8850", "source" : azurerm_subnet.kube_nodes.address_prefixes[0] },
      "Allow_TCP_8000" = { "priority" : "300", "port" : "8000", "source" : azurerm_subnet.kube_nodes.address_prefixes[0] },
      "Allow_TCP_5432" = { "priority" : "400", "port" : "5432", "source" : "192.168.0.0/24" },
    }
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      access                     = "Allow"
      protocol                   = "Tcp"
      direction                  = "Inbound"
      source_port_range          = "*"
      source_address_prefix      = security_rule.value.source
      destination_port_range     = security_rule.value.port
      destination_address_prefix = cidrhost(azurerm_subnet.tableau.address_prefixes[0], 4)
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "tableau" {
  count = var.tableau.enabled ? 1 : 0

  subnet_id                 = azurerm_subnet.tableau.id
  network_security_group_id = azurerm_network_security_group.tableau[0].id
}

resource "azurerm_monitor_diagnostic_setting" "tableau_nsg" {
  count = var.tableau.enabled ? 1 : 0

  name                       = "loganalytics"
  target_resource_id         = azurerm_network_security_group.tableau[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.i.id

  enabled_log { category = "NetworkSecurityGroupEvent" }
  enabled_log { category = "NetworkSecurityGroupRuleCounter" }
}


resource "azurerm_network_interface" "tableau" {
  count = var.tableau.enabled ? 1 : 0

  name                          = "${azurerm_resource_group.i.name}-tableau"
  location                      = azurerm_resource_group.i.location
  resource_group_name           = azurerm_resource_group.i.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "config"
    subnet_id                     = azurerm_subnet.tableau.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.tableau.address_prefixes[0], 4)
  }
}

resource "azurerm_linux_virtual_machine" "tableau" {
  count = var.tableau.enabled ? 1 : 0

  name                = "${azurerm_resource_group.i.name}-tableau"
  resource_group_name = azurerm_resource_group.i.name
  location            = azurerm_resource_group.i.location
  size                = var.tableau.size
  admin_username      = "tableau"
  network_interface_ids = [
    azurerm_network_interface.tableau[0].id,
  ]

  # Stored in 1Password, "SSH Key - Tableau", DevOps Vault.
  admin_ssh_key {
    username   = "tableau"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcJSNXP6UyEAMP2hKvh1+w4ldQ01vXrSY5wuKVBvJUEbqZjugExwqVj/kCtxHJW3fby2U6xgziZa5FRIxdOLD5ljcz6GBmWSxnaXU6tnvNkenZSUjnny2CJF4JcdmW7CMjD8m8ZrhGyMvgW++7i4nD5XfpxM1UKIeUIa4pFA3kCPY7gfW0Mi3i5eNDIvkRi9cIOGawcuQN9GRoDFv2QWMa2rk+ufm/JeZc26TgZTtLqlQ5SjEa6FGaf6zFnKvueAHbakqMRet3tPnZwGwV92wL4zs5PxtlCtamXH1LSggcK77/GyeKmaYmQ/b/MSvIMvPHaKAF1cmwoLntZASg+dQJTsMMu7xU9ITZUeWEDvmjDOOd/G2Cyc4LP8ydV+rWCysx3PBx48wA4mRuVaFwE1b9w6/9B1OnG27qx/LSzNjpFYoL9Vz8pypwHruIx12eGxnFqlTLeEcUfOlE2s5OCUyR8Dn22ioupY4yXvWNEmsd9IhgWLW44eSmpf1deZzWNRCOG3NNRQ+b1wLrU5yhPAg8/qPwnTHGNzF2P4UjfL9AgGArNKN3VNH+TUSZVeKIPno2feshYcVBMRkVDJGRVr/ZU+q5N+Y9KZQE9l2zFvPNZN145k8djEWR//voZmtU2tgYEXwCfcNrOskcww9RsU1MO6wUs+j182wMh/L3W6tfqw=="
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 1024
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
