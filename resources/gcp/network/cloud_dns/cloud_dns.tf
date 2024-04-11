/*
  Creates new GCP cloud DNS.
*/

variable "turn_on" {}
variable "zone_name" {}
variable "dns_name" {}
variable "description" {}
variable "vpc_network" {}

resource "google_dns_managed_zone" "itself" {
  count       = var.turn_on == true ? 1 : 0
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  visibility  = "private"
  private_visibility_config {
    networks {
      network_url = var.vpc_network
    }
  }
}

output "zone_id" {
  value = try(google_dns_managed_zone.itself[0].id, null)
}
