terraform {
    required_providers {
        nextdns = {
            source = "amalucelli/nextdns"
        }
    }
}

resource "nextdns_profile" "i" {
    name = "Bink"
}

output "profile_id" {
    value = nextdns_profile.i.id
}
