/*
  Creates new GCP Virtual Private Cloud.
*/

variable "vpc_name_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "GCP VPC Name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "vpc_description" {
  type        = string
  default     = "This VPC is used by IBM Spectrum Scale"
  description = "Description of VPC"
}

variable "vpc_routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "Network-wide routing mode to use (valid: REGIONAL, GLOBAL)"
}

variable "turn_on" {}

resource "google_compute_network" "itself" {
  count                   = var.turn_on ? 1 : 0
  name                    = format("%s-vpc", var.vpc_name_prefix)
  description             = var.vpc_description
  routing_mode            = var.vpc_routing_mode
  auto_create_subnetworks = false
}

output "vpc_id" {
  value = try(google_compute_network.itself[0].id, null)
}

output "vpc_self_link" {
  value = try(google_compute_network.itself[0].self_link, null)
}
