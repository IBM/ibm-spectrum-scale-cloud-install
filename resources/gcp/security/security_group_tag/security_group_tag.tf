/*
  Creates new GCP firewall rule that allows a specific port to a specified tag
*/

variable "turn_on" {}
variable "vpc_ref" {}
variable "firewall_name_prefix" {}
variable "firewall_description" {}
variable "source_tags" {}
variable "target_tags" {}
variable "tcp_ports" {}
variable "udp_ports" {}

resource "google_compute_firewall" "itself" {
  count       = var.turn_on ? 1 : 0
  name        = var.firewall_name_prefix
  network     = var.vpc_ref
  description = var.firewall_description
  source_tags = var.source_tags
  target_tags = var.target_tags

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }

  dynamic "allow" {
    for_each = var.udp_ports
    content {
      protocol = "udp"
      ports    = [allow.value]
    }
  }
}

output "firewall_id" {
  value = google_compute_firewall.itself[*].id
}

output "firewall_uri" {
  value = google_compute_firewall.itself[*].self_link
}
