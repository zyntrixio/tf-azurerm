resource "azurerm_availability_set" "worker" {
    name = "${var.environment}-worker-as"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    platform_fault_domain_count = 2
    managed = true

    tags = var.tags
}

variable "pod_ip_configs" {
    default = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30
    ]
}

resource "azurerm_network_interface" "worker" {
    count = var.worker_count
    name = format("${var.environment}-worker-%02d-nic", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    depends_on = [azurerm_lb.lb]
    enable_accelerated_networking = true
    enable_ip_forwarding = true

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.0.id
        private_ip_address_allocation = "Dynamic"
        primary = true
    }

    dynamic "ip_configuration" {
        for_each = [for s in var.pod_ip_configs : {
            name = "${format("pod-%02d", s)}"
        }]

        content {
            name = ip_configuration.value.name
            subnet_id = azurerm_subnet.subnet.0.id
            private_ip_address_allocation = "Dynamic"
        }
    }
}

resource "azurerm_virtual_machine" "worker" {
    count = var.worker_count
    name = format("${var.environment}-worker-%02d", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    availability_set_id = azurerm_availability_set.worker.id
    network_interface_ids = [
        element(azurerm_network_interface.worker.*.id, count.index),
    ]
    vm_size = var.worker_vm_size
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = false

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "16.04-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = format("${var.environment}-worker-%02d-disk", count.index + 1)
        disk_size_gb = "32"
        caching = "ReadOnly"
        create_option = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    os_profile {
        computer_name = format("${var.environment}-worker-%02d", count.index + 1)
        admin_username = "terraform"
        custom_data = <<-EOF
      #cloud-config
      write_files:
      - encoding: b64
        content: K0JhUU1PNzUwWlU1U3R3QUp5SWk5Ulk4aWtPakZXR3Q3ODEyVTNUR0VCaExWM28zZXVpQlJEVGI4aDlkT25weGV1SlJoZEtCL3NNSTdPWHFiMHVHcGNqd3dZS2Zmbk5HbmlqMlV0cXFWRDVSNUdVRStaNFZYZ0ZXTlRNNVFzU3I4V0p3akRiWGFQMGV1SFhLSjFmM3RPbjd2Z3NCQjBsV0ozcVdjT0tXaVY2N2hKREpkUmtCeVVHQUhILzNYeXJXQ0dOMnBIL05teFN6M3pxNElUYkc2OGVoVklyNjVaQllEQllhekhuR1JHVkJ4bG9jZWNEd29zblFiWldnU1FVRWNISXBuTUV3WTRJRGJkOWlBOXB3YWxxNklqQjJoWml5bmdCdXlHOW0rOWhiZHBJQ1crTGpMUEcrRVBxRDFRM29US2d4MWpUL09ybHFYM3Z2WVNycXkybVFqNXhlcW1OdE1JYW5mLysranlxTnRLUytGSTVtNzkycWpIc3RPb3d6VkR3aTFHdVhraTY5Y3E0MVlHOFBaRm10emo5Zk5JUHhNQnZpUUtrN2lmK3VlQW9mbmF3enBpdTJuZG9ZeDlHaGtPSDJFZ2k4c0xMS3FkM1dTNjlXNG91TXBlSVJPTDcvMFFHR24wRHByTklMS3FCbXRIenRtcldBRERYSFNBcG9PL005aHhacTZwaWZ4aG1iZEFqa0h3WnpMWURXNjFza0g2a2o2bVdVVGJRWWhJQkpHVmNzNDZvelhncHJ6czJId0dYb3VqYmRPUUtPZGpJdmlGeTBkSzR1ZUs0alY5WFBmYlFPcUE2MW8vMWhIdnNxbXZ1RU1XRjFTOEdiSTJDU0JkdlFCZXB1Y2lHdzkvN285b1hCcngxdFJodFRzT2NQYlhDdGIzR3kvc3c9
        owner: root:root
        path: /etc/chef/encrypted_data_bag_secret
        permissions: '0600'
      chef:
        install_type: "omnibus"
        force_install: true
        server_url: "https://chef.uksouth.bink.sh:4444/organizations/bink"
        node_name: "${format("${var.environment}-worker-%02d", count.index + 1)}"
        environment: "${var.resource_group_name}"
        validation_name: "bink-validator"
        validation_cert: |
          -----BEGIN RSA PRIVATE KEY-----
          MIIEpAIBAAKCAQEA35brXbKNGcY4owTgT0O1XmF0amkdCMAE7D+5BscnmgTAazmq
          pkn1jf8sJftv6EIVrvXlUHBnjttu+wOqRPmXJkZHzBRsxi/oWvSzQsMpLoYc7s3D
          ekX+A0LiRwTzlMcTCcEreUOXi3g11AwnXFYzd4jP5DmFRizR4ks1ajnHWIx7SCni
          EQob9e9us/OFy8deiWgZi367pVWonZeISRfHFeyYIPVFtVThyb16fqrtXHkyOSLI
          LAbZoAjP80wTgz5BIP9gcwE7w/HYfo5Bl8bSeHnPk2l9zXJiNYz2ULmDqIrBQl+y
          2sFL7FUUPn/LiME8Hd0crQH8MxeSb5wuE2NYXwIDAQABAoIBAQDClWoyefB4TNz/
          an/4G5ndEH0rGl1tPwdJv088Sdf6H0aCSoZr/5OXR0pZp8/FVrXeNRujfJ9zYR7d
          j1wAeSKE6ccUIXZkqE7T0X+si4HsfkTxwtrrL7yXg/6/Bd0iTnoQFC/McfmSJETc
          TNN4dYCG9+bM3Q5SezEReph64NvO/5rZmPZfGOSpb+uaHkY+SbWn3Q07iW0qqLm2
          iC+AdPecOb7VTkO98APdN5C7TrixsVDLdXuA6x97T+wL87X0gaD8Dyf3Mlaoa052
          Ek+pe+MgFPdZL25Z+RAzG4SBnOCGwsSRFpi0UQJMNjclkryrPxYzFw7Q8zuDEtEn
          GJubLhW5AoGBAPI86/9EIGM9UO8tNly4dEA2Cm1uUKxCCPOfwafTpE9t3stPCDeO
          C7FIpDZ8eSzuuJrQf4Ki4nY0KgrN+ZCoiGtkpDiuophWPFWZCTgRjsl0CQH93fzZ
          VVDWn5IVIXVN+7fcjPIkJc2HlWKNeTBlf6QMfZWbBCt97RjnV0WZj2fjAoGBAOxK
          xuNA5fz9Ra4aX9EKYkRuIclk5fRCWaneMlkfvddRgpS0dW/yh4x3sYPNxX1efKpK
          8f6/CEw2yaebk6Fci7MM3XuFNywCZPGbhhRo5dEwm1agITbcTOMjhzRIJ82hsNMP
          mnx5t9OiFNtU/qRyZw2EVKug/Cgtelm+ziBjxd5VAoGADVyc6+y3GKJGN5s31295
          Qh14/8ZI/ud5lO6oAPjkpFj8JBzM6DuWm4XVQQgmqvrUBf4gOnV/pmOEOipYbMlP
          FRVtFY9UerCvDU2uu4AEb0pOQOTe/NaEJTxheu5ddRoDG4Y35BdoWmjzLYd+OtQu
          cT8bIkh1t2xvyqLgJn+s8F8CgYEAtfuZVejjuIavpbk2Vl7y89UGPH9zAz4epE82
          46Eoqq5iLXkWgVN+xdZhZyuRkE63IMh7vEEQePIxON7/QmVuSkX8RmeA6GonqFSp
          XQq1BPm0iXDmY8Qji0QPm1p/HUYMU2FPD9MGmv3Xply9iZV6fNSQCWcBDUiJVJk5
          U4TEHckCgYBjZNvspUT7BjhMRTj+55Qu/vxe+W49XTRlTY4TzVcQL6sJ0X28qrnk
          2Y4lblI7OXmwoXNsms4S3GvcszDZbsu16pm2MeUibP5MXRp1V9GRf9Y4Y0yrDvon
          kGgAf033beTHYzJa3XIp0XhF7+7SLwaF4Imje4Bp8FKJmVirQT2OYw==
          -----END RSA PRIVATE KEY-----
        run_list:
         - "role[worker]"
        omnibus_url: "https://www.chef.io/chef/install.sh"
        omnibus_version: "15.1.36"
      runcmd:
       - [ chef-client, --chef-license, accept ]
      output: {all: '| tee -a /var/log/cloud-init-output.log'}

    EOF
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path = "/home/terraform/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrdSta+Sv3YWupzHk4U1VS7jvUvkQgmWexanDnGHLx7YjBKxi1tuhE0WgzgkbB3WqDNLrj5dXdv9la8S9VvrL1L1r4YG+5N0f6Ri1xE+cGei6aFAm57eLPnGhAY6lxiPSx79x+cfmW0YdZHI/6rb4Gix+KoH4BOPZnshxjoyL5MJpel2/5LZHWuazT3ihzWXemhMQ11mXJGot+tuVRB3tkVg+vi//YyRo5vKQSjpvirrP8MgQY76jk0RzxhwsP1d+7lkeAcedPilNpmhP72rfWMTxkrbO7XQrZMpIeL7qywdaOb0tPEB0n9KscUwiMvM4oOLVizsgzKoUOZ91rkxhb id_bink_azure_terraform"
        }
    }

    tags = var.tags
}

module "worker_nsg_rules" {
    source = "../../modules/nsg_rules"
    network_security_group_name = "${var.environment}-subnet-01-nsg"
    resource_group_name = azurerm_resource_group.rg.name
    rules = [
        {
            name = "BlockEverything"
            priority = "4096"
            access = "Deny"
        },
        {
            name = "AllowLoadBalancer"
            source_address_prefix = "AzureLoadBalancer"
            priority = "4095"
        },
        {
            name = "AllowSSH"
            priority = "500"
            protocol = "TCP"
            destination_port_range = "22"
            destination_address_prefix = var.subnet_address_prefixes[0]
            source_address_prefix = "192.168.4.0/24"
        },
        {
            name = "AllowAllSubnetTraffic"
            priority = "100"
            source_address_prefix = var.subnet_address_prefixes[0]
            destination_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowAllControllerSubnetTraffic"
            priority = "110"
            source_address_prefix = var.subnet_address_prefixes[1]
            destination_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowHttpTraffic"
            priority = "120"
            destination_port_range = "30000"
            protocol = "TCP"
            destination_address_prefix = var.subnet_address_prefixes[0]
        },
        {
            name = "AllowHttpsTraffic"
            priority = "130"
            destination_port_range = "30001"
            protocol = "TCP"
            destination_address_prefix = var.subnet_address_prefixes[0]
        }
    ]
}

module "worker_lb_rules" {
    source = "../../modules/lb_rules"
    loadbalancer_id = azurerm_lb.lb.id
    backend_id = azurerm_lb_backend_address_pool.pools.0.id
    resource_group_name = azurerm_resource_group.rg.name
    frontend_ip_configuration_name = "subnet-01"

    lb_port = {
        ingress_http = ["80", "TCP", "30000"]
        ingress_https = ["443", "TCP", "30001"]
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "worker-bap-pools-assoc" {
    count = var.worker_count
    network_interface_id = element(azurerm_network_interface.worker.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pools.0.id
}
