# Terraform / Azure

---
**NOTE**

`chef.pem` needs to be populated in this projects root directory. Please find this in the DevOps Vault in 1Password

CI Now runs `terrafmt --check` so you'll probably want to setup a pre commit hook. https://github.com/terrycain/terrafmt/releases terrafmt-darwin-amd64.zip is what you'll want.

---


## UKSouth Deployment Order

1. Deploy the region pre-requisites - `uksouth-common/ `
2. Set up pre-requisite secrets / info `uksouth-common/README.md`
3. Deploy environments `uksouth/`
