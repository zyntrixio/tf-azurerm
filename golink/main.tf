terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "tailscale" {
  type = object({
    client_secret = string
  })
  default = {
    client_secret = "tskey-client-kc7cDo5CNTRL-eKbaiSFA7FKzrBcaTaFxEKvgrkNHFFKvR"
  }
}

data "cloudinit_config" "i" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
    #cloud-config
    runcmd:
      - ["sh", "-c", "curl -fsSL https://tailscale.com/install.sh | sh"]
      - ["tailscale", "up", "--authkey=${var.tailscale.client_secret}", "--advertise-tags=tag:terraform"]
      - ["tailscale", "set", "--ssh"]
      - ["tailscale", "set", "--accept-dns=false"]
    EOF
  }
}

resource "digitalocean_project" "i" {
  name        = "Tailscale Golink"
  description = "https://github.com/tailscale/golink"
  environment = "Production"
  resources   = [digitalocean_droplet.i.urn]
}

resource "digitalocean_droplet" "i" {
  image     = "debian-12-x64"
  name      = "golink"
  region    = "lon1"
  size      = "s-1vcpu-1gb"
  ssh_keys  = ["4b:8e:3c:cd:d6:e8:11:2c:ed:9c:40:49:00:b1:e6:c5"]
  user_data = data.cloudinit_config.i.rendered
}

resource "digitalocean_firewall" "i" {
  name        = "tailscale"
  droplet_ids = [digitalocean_droplet.i.id]
  inbound_rule {
    protocol         = "udp"
    port_range       = "41641"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
