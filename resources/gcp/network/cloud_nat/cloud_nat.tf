/*
  Creates new GCP cloud router NAT.
*/

variable "nat_name" {
  type        = string
  default     = "spectrum-scale-nat"
  description = "GCP Cloud router NAT name"
}

variable "router_name" {
  type        = string
  default     = "spectrum-scale-router"
  description = "GCP Cloud router name"
}

variable "private_subnet_name" {
  type        = string
  description = "Reference to the network to which this router belongs"
}


resource "google_compute_router_nat" "nat" {
  name   = var.nat_name
  router = var.router_name

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = var.private_subnet_name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}


output "cloud_nat_id" {
  value = google_compute_router_nat.nat.id
}
