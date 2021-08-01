# Terraform / Azure

## Environment Variables

Shell Environment Variables need to be set for Terraform operation, these can be found in 1Password in the DevOps Vault [here](https://bink.1password.com/vaults/k5lbodflcbgmnahxrxu2rvmbey/allitems/ij3bqa4mmvgcbe63we3zsiscju)

Fish:
```
set -Ux TF_VAR_azurerm_terraform_client_id <secret>
```

ZSH:
```
echo "export TF_VAR_azurerm_terraform_client_id=<secret> >> ~/.zshrc
source ~/.zshrc
```

## Chef Certificates

`chef.pem` needs to be populated in this projects root directory. Please find this in the DevOps Vault in 1Password

CI Now runs `terrafmt --check` so you'll probably want to setup a pre commit hook. https://github.com/terrycain/terrafmt/releases terrafmt-darwin-amd64.zip is what you'll want.


## Firewall IP Assigments

* `azurerm_public_ip.pips.0.id`
    * IP Address: 51.132.44.240
    * Environment: Production
* `azurerm_public_ip.pips.1.id`
    * IP Address: 51.132.44.241
    * Environment: Pre-Production
* `azurerm_public_ip.pips.2.id`
    * IP Address: 51.132.44.242
    * Environment: Staging
* `azurerm_public_ip.pips.3.id`
    * IP Address: 51.132.44.243
    * Environment: Dev
* `azurerm_public_ip.pips.4.id`
    * IP Address: 51.132.44.244
    * Envrionment: Sandbox
* `azurerm_public_ip.pips.5.id`
    * IP Address: 51.132.44.245
    * Environment: Tools
* `azurerm_public_ip.pips.6.id`
    * IP Address: 51.132.44.246
    * Environment: Performance
* `azurerm_public_ip.pips.7.id`
    * IP Address: 51.132.44.247
    * Environment: Aqua
* `azurerm_public_ip.pips.8.id`
    * IP Address: 51.132.44.248
    * Environment: GitLab
* `azurerm_public_ip.pips.9.id`
    * IP Address: 51.132.44.249
    * Environment: Unassigned
* `azurerm_public_ip.pips.10.id`
    * IP Address: 51.132.44.250
    * Environment: Unassigned
* `azurerm_public_ip.pips.11.id`
    * IP Address: 51.132.44.251
    * Environment: Unassigned
* `azurerm_public_ip.pips.12.id`
    * IP Address: 51.132.44.252
    * Environment: Unassigned
* `azurerm_public_ip.pips.13.id`
    * IP Address: 51.132.44.253
    * Environment: Unassigned
* `azurerm_public_ip.pips.14.id`
    * IP Address: 51.132.44.254
    * Environment: Unassigned
* `azurerm_public_ip.pips.15.id`
    * IP Address: 51.132.44.255
    * Environment: Production (SFTP)
