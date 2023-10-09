/*
  Creates new GCP firewall rule that allows a specific port to a specified tag
*/

variable "turn_on" {}
variable "vpc_ref" {}
variable "firewall_name_prefix" {}
variable "firewall_description" {}
variable "source_tags" {}
variable "target_tags" {}
variable "protocols" {}
variable "ports" {}

resource "google_compute_firewall" "itself" {
  count       = var.turn_on ? length(var.protocols) : 0
  name        = var.protocols[count.index] == "icmp" ? format("%s-allow-icmp", var.firewall_name_prefix) : format("%s-allow-%s-%s", var.firewall_name_prefix, lower(var.protocols[count.index]), var.ports[count.index])
  network     = var.vpc_ref
  description = element(var.firewall_description, count.index)
  source_tags = var.source_tags
  target_tags = var.target_tags

  dynamic "allow" {
    for_each = var.protocols[count.index] == "icmp" ? ["icmp"] : []
    content {
      protocol = "icmp"
    }
  }

  dynamic "allow" {
    for_each = var.protocols[count.index] != "icmp" ? [var.ports[count.index]] : []
    content {
      protocol = var.protocols[count.index]
      ports    = [var.ports[count.index]]
    }
  }
}

output "firewall_id" {
  value = google_compute_firewall.itself[*].id
}

output "firewall_uri" {
  value = google_compute_firewall.itself[*].self_link
}
