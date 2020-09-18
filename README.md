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
