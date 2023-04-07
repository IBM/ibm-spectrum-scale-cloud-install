/*
  Creates new GCP firewall rule for enable internal subnet access
*/

variable "firewall_name_prefix" {
  type        = string
  description = "GCP firewall name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "vpc_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "VPC name to which this firewall should be associated"
}

variable "firewall_description" {
  type        = string
  default     = "Firewall rule to allow internal network access."
  description = "Description of the firewall"
}

variable "subnet_cidr_range" {
  type        = list(string)
  description = "Firewall will apply to traffic to this subnet ranges."
}

variable "vm_tags" {
  type        = list(string)
  description = "Source or target tags where firewall to be applied."
}

variable "turn_on" {}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "allow_internal_ingress" {
  count         = tobool(var.turn_on) == true ? 1 : 0
  name          = format("%s-allow-internal-ingress", var.firewall_name_prefix)
  network       = var.vpc_ref
  description   = "${var.firewall_description} - ingress traffic"
  source_ranges = var.subnet_cidr_range

  allow {
    protocol = "all"
  }

  direction = "INGRESS"

  target_tags = var.vm_tags
}

resource "google_compute_firewall" "allow_internal_egress" {
  count       = tobool(var.turn_on) == true ? 1 : 0
  name        = format("%s-allow-internal-egress", var.firewall_name_prefix)
  network     = var.vpc_ref
  description = "${var.firewall_description} - egress traffic"

  allow {
    protocol = "all"
  }

  direction = "EGRESS"

  destination_ranges = var.subnet_cidr_range
}

#Ingress
output "firewall_id_ingress" {
  value = google_compute_firewall.allow_internal_ingress[*].id
}

output "firewall_name_ingress" {
  value      = format("%s-allow-internal-ingress", var.firewall_name_prefix)
  depends_on = [google_compute_firewall.allow_internal_ingress]
}

output "firewall_uri_ingress" {
  value = google_compute_firewall.allow_internal_ingress[*].self_link
}

#Egress
output "firewall_id_egress" {
  value = google_compute_firewall.allow_internal_egress[*].id
}

output "firewall_name_egress" {
  value      = format("%s-allow-internal-egress", var.firewall_name_prefix)
  depends_on = [google_compute_firewall.allow_internal_egress]
}

output "firewall_uri_egress" {
  value = google_compute_firewall.allow_internal_egress[*].self_link
}
