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
  type        = list(string)
  nullable    = true
  default     = null
  description = "Description of the firewall"
}

variable "source_ranges" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "source cidr where firewall to be applied."
}

variable "destination_ranges" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "Destination cidr where firewall to be applied."
}

variable "destination_range_egress_all" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "Destination cidr range for egress to allow all ports."
}

variable "protocol" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "Protocols of the firewall"
}

variable "ports" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "Firewall ports to be applied."
}

variable "turn_on_ingress" {
  type    = bool
  default = false
}

variable "turn_on_ingress_bi" {
  type    = bool
  default = false
}

variable "turn_on_egress" {
  type    = bool
  default = false
}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "allow_protocal_ingress" {
  count         = (tobool(var.turn_on_ingress) == true && var.source_ranges != null) ? length(var.protocol) : 0
  name          = var.protocol[count.index] == "icmp" ? format("%s-allow-ingress-icmp", var.firewall_name_prefix) : format("%s-allow-ingress-%s-%s", var.firewall_name_prefix, lower(var.protocol[count.index]), var.ports[count.index])
  network       = var.vpc_ref
  description   = "${var.firewall_description[count.index]} - ingress traffic"
  source_ranges = var.source_ranges

  dynamic "allow" {
    for_each = var.protocol[count.index] == "icmp" ? ["icmp"] : []
    content {
      protocol = "icmp"
    }
  }

  dynamic "allow" {
    for_each = var.protocol[count.index] != "icmp" ? [var.ports[count.index]] : []
    content {
      protocol = var.protocol[count.index]
      ports    = [var.ports[count.index]]
    }
  }

  direction = "INGRESS"
}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "allow_protocal_ingress_bi" {
  count         = (tobool(var.turn_on_ingress_bi) == true && var.source_ranges != null && var.destination_ranges != null) ? length(var.protocol) : 0
  name          = var.protocol[count.index] == "icmp" ? format("%s-allow-ingress-icmp", var.firewall_name_prefix) : format("%s-allow-ingress-%s-%s", var.firewall_name_prefix, lower(var.protocol[count.index]), var.ports[count.index])
  network       = var.vpc_ref
  description   = "${var.firewall_description[count.index]} - ingress traffic"
  source_ranges = var.source_ranges

  dynamic "allow" {
    for_each = var.protocol[count.index] == "icmp" ? ["icmp"] : []
    content {
      protocol = "icmp"
    }
  }

  dynamic "allow" {
    for_each = var.protocol[count.index] != "icmp" ? [var.ports[count.index]] : []
    content {
      protocol = var.protocol[count.index]
      ports    = [var.ports[count.index]]
    }
  }

  direction          = "INGRESS"
  destination_ranges = var.destination_ranges
}

#tfsec:ignore:google-compute-no-public-egress
resource "google_compute_firewall" "allow_protocal_egress" {
  count       = tobool(var.turn_on_egress) == true && var.destination_ranges != null ? length(var.protocol) : 0
  name        = var.protocol[count.index] == "icmp" ? format("%s-allow-egress-icmp", var.firewall_name_prefix) : format("%s-allow-egress-%s-%s", var.firewall_name_prefix, var.protocol[count.index], lower(var.protocol[count.index]), var.ports[count.index])
  network     = var.vpc_ref
  description = "${var.firewall_description[count.index]} - egress traffic"

  dynamic "allow" {
    for_each = var.protocol[count.index] == "icmp" ? ["icmp"] : []
    content {
      protocol = "icmp"
    }
  }

  dynamic "allow" {
    for_each = var.protocol[count.index] != "icmp" ? [var.ports[count.index]] : []
    content {
      protocol = var.protocol[count.index]
      ports    = [var.ports[count.index]]
    }
  }

  direction          = "EGRESS"
  destination_ranges = var.destination_ranges
}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "allow_internal_egress_all" {
  count       = tobool(var.turn_on_egress) == true && var.destination_range_egress_all != null ? 1 : 0
  name        = format("%s-allow-all-egress", var.firewall_name_prefix)
  network     = var.vpc_ref
  description = "${var.firewall_description[0]} - ingress traffic"

  allow {
    protocol = "all"
  }

  direction = "EGRESS"

  destination_ranges = var.destination_range_egress_all
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

#Ingress bi
output "firewall_id_ingress_bi" {
  value = google_compute_firewall.allow_protocal_ingress_bi[*].id
}

output "firewall_name_ingress_bi" {
  value      = format("%s-allow-ingress-bi", var.firewall_name_prefix)
  depends_on = [google_compute_firewall.allow_protocal_ingress_bi]
}

output "firewall_uri_ingress_bi" {
  value = google_compute_firewall.allow_protocal_ingress_bi[*].self_link
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

output "firewall_uri_egress_all" {
  value = google_compute_firewall.allow_internal_egress_all[*].self_link
}
