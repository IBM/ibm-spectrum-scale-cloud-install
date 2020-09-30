/*
  Creates new GCP cloud router.
*/

variable "router_name" {
  type        = string
  default     = "spectrum-scale-router"
  description = "GCP Cloud router name"
}

variable "vpc_name" {
  type        = string
  description = "Reference to the network to which this router belongs"
}


resource "google_compute_router" "router" {
  name    = var.router_name
  network = var.vpc_name

  bgp {
    asn = 64514
  }
}


output "router_name" {
  value      = var.router_name
  depends_on = [google_compute_router.router]
}

output "router_id" {
  value = google_compute_router.router.id
}

output "router_uri" {
  value = google_compute_router.router.self_link
}
