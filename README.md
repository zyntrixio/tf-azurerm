# Terraform / Azure

---
**NOTE**

`chef.pem` needs to be populated in this projects root directory. Please find this in the DevOps Vault in 1Password

CI Now runs `terrafmt --check` so you'll probably want to setup a pre commit hook. https://github.com/terrycain/terrafmt/releases terrafmt-darwin-amd64.zip is what you'll want.

---

## Chef and commandpersistence providers
For the Chef part, you'll need `knife` set up correctly, Chef key at `~/.chef/user.pem` and `~/.chef/username` containing your username. `cfssl` needs to be installed.

If you want to import Chef resources, you'll need to build `https://github.com/terrycain/terraform-provider-chef/tree/import` this provider as import functionality has not been merged yet.

Until the Terraform Registry is out of beta, you'll need `https://github.com/terrycain/terraform-provider-commandpersistence` there is a Darwin release on that which you can place in the terraform plugins folder. This provider does exactly what the Terraform `external` provider does except it runs the command once on apply, instead of everytime a plan is performed. Eventually want to update it to specify other actions on delete/update so can act like a generic resource and manage the lifecycle better.

Custom Terraform providers need to be placed in `~/.terraform.d/plugins/`. E.g. `~/.terraform.d/plugins/terraform-provider-commandpersistence`




## UKSouth Deployment Order

1. Deploy the region pre-requisites - `uksouth-common/ `
2. Set up pre-requisite secrets / info `uksouth-common/README.md`
3. Deploy environments `uksouth/`
