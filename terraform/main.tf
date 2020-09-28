terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {}

resource "digitalocean_droplet" "minecraft1" {
  image    = "centos-8-x64"
  name     = "minecraft1"
  region   = "nyc1"
  size     = "s-1vcpu-2gb"
  ipv6     = true
  ssh_keys = [28579834]
}

resource "digitalocean_domain" "domain" {
  name = "scrabblicious.com"
}

resource "digitalocean_record" "minecraft1_v4" {
  domain = digitalocean_domain.domain.name
  type   = "A"
  ttl    = "60"
  name   = "minecraft1"
  value  = digitalocean_droplet.minecraft1.ipv4_address
}

resource "digitalocean_record" "minecraft1_v6" {
  domain = digitalocean_domain.domain.name
  type   = "AAAA"
  ttl    = "60"
  name   = "minecraft1"
  value  = digitalocean_droplet.minecraft1.ipv6_address
}

resource "digitalocean_firewall" "minecraft_firewall" {
  name = "only-22-and-25565"

  droplet_ids = [digitalocean_droplet.minecraft1.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "25565"
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
