terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {}

resource "digitalocean_droplet" "factorio1" {
  image    = "fedora-34-x64"
  name     = "factorio1"
  region   = "nyc1"
  size     = "s-1vcpu-2gb"
  ipv6     = true
  ssh_keys = [30503585, 30503589]
}

resource "digitalocean_domain" "domain" {
  name = "scrabblicious.com"
}

resource "digitalocean_record" "factorio1_v4" {
  domain = digitalocean_domain.domain.name
  type   = "A"
  ttl    = "60"
  name   = "factorio1"
  value  = digitalocean_droplet.factorio1.ipv4_address
}

resource "digitalocean_record" "factorio1_v6" {
  domain = digitalocean_domain.domain.name
  type   = "AAAA"
  ttl    = "60"
  name   = "factorio1"
  value  = digitalocean_droplet.factorio1.ipv6_address
}

resource "digitalocean_firewall" "factorio_firewall" {
  name = "only-22-and-34197"

  droplet_ids = [digitalocean_droplet.factorio1.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "34197"
    source_addresses = ["0.0.0.0/0", "::/0"]
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
