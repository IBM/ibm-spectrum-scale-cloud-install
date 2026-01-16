/*
  Creates new GCP firewall rule
*/

variable "firewall_name_prefix" {
  type        = string
  description = "GCP firewall name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "vpc_name" {
  type        = string
  default     = "spectrum-scale-vpc"
  description = "VPC name to which this firewall should be associated"
}

variable "firewall_description" {
  type        = string
  default     = "Firewall rule to allow icmp, ssh to Bastion instance"
  description = "Description of the firewall"
}

variable "traffic_port" {
  type = string
}

variable "source_range" {
  type        = list(string)
  description = "Firewall will apply only to traffic that has source IP address in these ranges"
}

resource "google_compute_firewall" "itself" {
  name        = format("%s-allow-bastion", var.firewall_name_prefix)
  network     = var.vpc_name
  description = var.firewall_description
  #tfsec:ignore:google-compute-no-public-ingress
  source_ranges = var.source_range

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [var.traffic_port]
  }
}

output "firewall_id" {
  value = google_compute_firewall.itself.id
}

output "firewall_name" {
  value      = format("%s-allow-bastion", var.firewall_name_prefix)
  depends_on = [google_compute_firewall.itself]
}

output "firewall_uri" {
  value = google_compute_firewall.itself.self_link
}
