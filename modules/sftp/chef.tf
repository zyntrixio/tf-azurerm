resource "chef_environment" "env" {
    name = var.resource_group_name
    cookbook_constraints = {
        fury = ">= 1.6.1"
        nebula = "= 2.1.0"
    }

    default_attributes_json = jsonencode(var.sftp_users)
}
