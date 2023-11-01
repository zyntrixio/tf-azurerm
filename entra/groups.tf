resource "azuread_group" "example" {
    display_name = "terraform-example"
    security_enabled = true
}
