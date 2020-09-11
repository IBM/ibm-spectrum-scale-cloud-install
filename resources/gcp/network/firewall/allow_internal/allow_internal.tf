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
  default     = "Firewall rule to allow ssh to private network instances"
  description = "Description of the firewall"
}

variable "source_range" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Firewall will apply only to traffic that has source IP address in these ranges"
}


resource "google_compute_firewall" "allow_internal" {
  name          = format("%s-allow-internal", var.firewall_name_prefix)
  network       = var.vpc_name
  description   = var.firewall_description
  source_ranges = var.source_range
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}


output "firewall_id" {
  value = google_compute_firewall.allow_internal.id
}

output "firewall_name" {
  value      = format("%s-allow-bastion", var.firewall_name_prefix)
  depends_on = [google_compute_firewall.allow_internal]
}

output "firewall_uri" {
  value = google_compute_firewall.allow_internal.self_link
}
