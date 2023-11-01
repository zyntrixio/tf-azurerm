module "entra" {
    source = "./entra"
    users = {
        "tftestuser01" = {
            name = "Terraform Test User 1"
            job_title = "Ultra Nerd"
            enabled = true
        }
        "tftestuser02" = {
            name = "Terraform Test User 2"
            job_title = "Super Nerd"
            manager = "cpressland"
            enabled = true
        }
    }
    groups = {
        "terraform_test_group_01" = {
            name = "Terraform Test Group 1"
            members = [
                "tftestuser01",
                "tftestuser02",
            ]
        }
    }
}
