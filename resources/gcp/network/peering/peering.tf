variable "pair_name" {}
variable "network_a" {}
variable "network_b" {}

resource "google_compute_network_peering" "itself" {
  name                 = var.pair_name
  network              = var.network_a
  peer_network         = var.network_b
  import_custom_routes = true
  export_custom_routes = true
}

output "peer_state" {
  value = google_compute_network_peering.itself.state
}
