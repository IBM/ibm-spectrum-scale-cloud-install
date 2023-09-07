/*
  Creates new GCP cloud router NAT.
*/

variable "nat_name" {}
variable "router_name" {}
variable "private_subnet_id" {}
variable "turn_on" {}

resource "google_compute_router_nat" "itself" {
  count  = var.turn_on == true ? length(var.private_subnet_id) : 0
  name   = "${var.nat_name}-${count.index}"
  router = var.router_name

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = element(var.private_subnet_id, count.index)
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

output "cloud_nat_id" {
  value = google_compute_router_nat.itself[*].id
}
