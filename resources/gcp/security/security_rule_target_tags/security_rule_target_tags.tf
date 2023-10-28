/*
  Creates new GCP firewall rule that allows a specific port from a specified source range to a target tag
*/

variable "turn_on" {}
variable "vpc_ref" {}
variable "firewall_name_prefix" {}
variable "firewall_description" {}
variable "source_ranges" {}
variable "target_tags" {}
variable "ports" {}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "itself" {
  count         = var.turn_on ? 1 : 0
  name          = var.firewall_name_prefix
  network       = var.vpc_ref
  description   = var.firewall_description
  source_ranges = var.source_ranges
  target_tags   = var.target_tags

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.ports
  }
}

output "firewall_id" {
  value = google_compute_firewall.itself[*].id
}

output "firewall_uri" {
  value = google_compute_firewall.itself[*].self_link
}
