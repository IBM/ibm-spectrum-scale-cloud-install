/*
  Creates new GCP firewall rule to enable specific protocol and ports
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

variable "source_vm_tags" {
  type        = list(string)
  description = "Source or target tags where firewall to be applied."
}

variable "destination_vm_tags" {
  type        = list(string)
  description = "Destination or target tags where firewall to be applied."
}

variable "protocol" {
  type        = string
  default     = "Firewall protocol to be applied."
  description = "Description of the firewall"
}

variable "ports" {
  type        = list(number)
  description = "Firewall ports to be applied."
}

variable "turn_on_ingress" {
  type    = bool
  default = true
}

variable "turn_on_egress" {
  type    = bool
  default = false
}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "allow_protocal_ingress" {
  count       = tobool(var.turn_on_ingress) == true ? 1 : 0
  name        = format("%s-allow-ingress", var.firewall_name_prefix)
  network     = var.vpc_ref
  description = "${var.firewall_description} - ingress traffic"

  dynamic "allow" {
    for_each = var.ports[0] == -1 ? ["icmp"] : []
    content {
      protocol = "icmp"
    }
  }

  dynamic "allow" {
    for_each = var.ports[0] != -1 ? ["tcp_udp"] : []
    content {
      protocol = var.protocol
      ports    = var.ports
    }
  }

  direction = "INGRESS"

  source_tags = var.source_vm_tags
  target_tags = var.destination_vm_tags
}

#tfsec:ignore:google-compute-no-public-egress
resource "google_compute_firewall" "allow_protocal_egress" {
  count       = tobool(var.turn_on_egress) == true ? 1 : 0
  name        = format("%s-allow-egress", var.firewall_name_prefix)
  network     = var.vpc_ref
  description = "${var.firewall_description} - egress traffic"

  allow {
    protocol = var.protocol
    ports    = var.ports
  }

  direction = "EGRESS"
}

#Ingress
output "firewall_id_ingress" {
  value = google_compute_firewall.allow_protocal_ingress[*].id
}

output "firewall_name_ingress" {
  value      = format("%s-allow-ingress", var.firewall_name_prefix)
  depends_on = [google_compute_firewall.allow_protocal_ingress]
}

output "firewall_uri_ingress" {
  value = google_compute_firewall.allow_protocal_ingress[*].self_link
}

#Egress
output "firewall_id_egress" {
  value = google_compute_firewall.allow_protocal_egress[*].id
}

output "firewall_name_egress" {
  value      = format("%s-allow-egress", var.firewall_name_prefix)
  depends_on = [google_compute_firewall.allow_protocal_egress]
}

output "firewall_uri_egress" {
  value = google_compute_firewall.allow_protocal_egress[*].self_link
}
