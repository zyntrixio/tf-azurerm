terraform {
  required_providers {
    nextdns = {
      source = "amalucelli/nextdns"
    }
  }
}

variable "rewrites" {
  type = map(string)
}

resource "nextdns_profile" "i" {
  name = "Bink"
}

output "profile_id" {
  value = nextdns_profile.i.id
}


resource "nextdns_rewrite" "i" {
  profile_id = nextdns_profile.i.id

  dynamic "rewrite" {
    for_each = var.rewrites
    content {
      domain  = rewrite.key
      address = rewrite.value
    }
  }
}
