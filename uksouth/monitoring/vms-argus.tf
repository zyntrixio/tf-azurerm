resource "azurerm_availability_set" "argus" {
    name = "${var.environment}-argus-as"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    platform_fault_domain_count = 2
    managed = true

    tags = var.tags
}

resource "azurerm_network_interface" "argus" {
    count = var.argus_count
    name = format("${var.environment}-argus-%02d-nic", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    depends_on = [azurerm_lb.lb]

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.subnet.5.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "argus" {
    count = var.argus_count
    name = format("${var.environment}-argus-%02d", count.index + 1)
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [
        element(azurerm_network_interface.argus.*.id, count.index),
    ]
    vm_size = var.argus_vm_size
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = false

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = format("${var.environment}-argus-%02d-disk", count.index + 1)
        disk_size_gb = "200"
        caching = "ReadOnly"
        create_option = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    os_profile {
        computer_name = format("${var.environment}-argus-%02d", count.index + 1)
        admin_username = "terraform"
        custom_data = <<-EOF
      #cloud-config
      write_files:
      - encoding: b64
        content: UnhpSjBHdHpnRTQ2WFJjUWV4YTUyNFV3MkZWY05IaUY1cHl3amVQc1A5ZHRHUzlyR29IdWFpdkZ5S2REM2NKMWZQRWsxRkwwQVNoclBrRlRDUTNpNkh6bDFQT1NKdWJSdC9hbjdlNDNJc0NMVkV4RDA3NXl6Si9uVDdNajVvTm1HWmxCdGlvMEI5Ris2c1VJdUFpc21SbXdjZTNyK28xclJaeVY0WWNyMExXMlVjMXVSL0RlWXJEbWM3dzg2QkNYa01OS2RSOGdIV2ZkU2ROTWU4TnRPR2FBTmZqbm5wc0lFcEhFeExJemF0eXdLREgxenhjMVRkaWVkVlhsN0xydHltS21TempqUGx1M3BvZnZkQ2RFSGNYSUdoRVltVUVhL3JraEVNaUJkeEVxZkpSeDBRMlNlY2hZSFlnblk0WWFIWHRSeTA0MWxlSkRod1grWFlQU1dHV1VLWnNKRExjc05yclJQRi8rMS9xTkgwVmJENXB6c1pqUml2UllUMUcrYUl1aHIyUWlqN0tKZVltZENrM2lsTFhZMlR3NGZyQys3Nmd0OFllbDBTTUxJMzZSWU1KMlVNWWYwMUt3K0hVa0Vod3RieDdQdXJpTXh2NklkaHFRMGdxZXJFUTVQTFE3VG1zN0dnS3RtSThEVVMzdXNWeENmeXlNdzFSZ1E2anVPRDB2dUtQTGNNVFRSWnJ5MTJiSUtJL0d1bFlYZlJCSmRMd3Q1dGJQNDNZaVltSDJsSVVway9ENHdVMWJyL2FMcCs2T2hwU1R1K0RCMktLV3IyN0JIeDZid05idWRTN2o2RGtUUnNXelFQMHRqeHlTQ0tBMjU3Q3JkaitRV3ZONHFjY01JOEorVW5relJsb0YrVzVyNkVVdThwNkdXOGRrRGQ3dTJLcmRlS0U9
        owner: root:root
        path: /etc/chef/encrypted_data_bag_secret
        permissions: '0600'
      chef:
        install_type: "omnibus"
        force_install: true
        server_url: "https://chef.uksouth.bink.sh:4444/organizations/bink"
        node_name: "${format("${var.environment}-argus-%02d", count.index + 1)}"
        environment: "${azurerm_resource_group.rg.name}"
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
         - "role[argus]"
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

module "argus_nsg_rules" {
    source = "../../modules/nsg_rules"
    network_security_group_name = "${var.environment}-subnet-06-nsg"
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
            source_address_prefix = "192.168.4.0/24"
            destination_address_prefix = var.subnet_address_prefixes[5]
        },
        {
            name = "AllowArgusAccessBinkHQ"
            priority = "100"
            protocol = "TCP"
            destination_port_range = "8001"
            source_address_prefix = "192.168.0.0/24"
            destination_address_prefix = var.subnet_address_prefixes[5]
        },
        {
            name = "AllowHTTP_PrometheusNodeExporter"
            priority = "110"
            protocol = "TCP"
            destination_port_range = "9100"
            source_address_prefix = "192.168.6.64/28"
            destination_address_prefix = var.subnet_address_prefixes[5]
        }
    ]
}

module "argus_lb_rules" {
    source = "../../modules/lb_rules"
    loadbalancer_id = azurerm_lb.lb.id
    backend_id = azurerm_lb_backend_address_pool.pools.5.id
    resource_group_name = azurerm_resource_group.rg.name
    frontend_ip_configuration_name = "subnet-06"

    lb_port = {
        argus = ["8001", "TCP", "8001"]
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "argus-bap-pools-assoc" {
    count = var.argus_count
    network_interface_id = element(azurerm_network_interface.argus.*.id, count.index)
    ip_configuration_name = "primary"
    backend_address_pool_id = azurerm_lb_backend_address_pool.pools.5.id
}