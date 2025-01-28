/*
  Creates new GCP cloud router.
*/

variable "route_name" {}
variable "destination_range" {}
variable "network_name" {}
variable "next_hop_instance" {}
variable "rule_priority" {}

resource "google_compute_route" "itself" {
  name              = var.route_name
  dest_range        = var.destination_range
  network           = var.network_name
  next_hop_instance = var.next_hop_instance
  priority          = var.rule_priority
}

output "route_id" {
  value = google_compute_route.itself.id
}

output "route_uri" {
  value = google_compute_router.itself.self_link
}
