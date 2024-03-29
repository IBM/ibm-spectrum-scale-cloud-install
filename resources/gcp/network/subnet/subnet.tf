/*
  Creates new GCP subnet.
*/

variable "vpc_name" {
  type        = string
  default     = "spectrum-scale-vpc"
  description = "VPC name to which this subnet should be associated"
}

variable "subnet_name_prefix" {
  type        = string
  description = "GCP subnet name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "subnet_description" {
  type        = string
  description = "Description of the subnet"
}

variable "private_google_access" {
  type        = bool
  default     = false
  description = "When enabled, VMs in this subnetwork without external IP addresses can access Google APIs"
}

variable "subnet_cidr_range" {}
variable "turn_on" {}

#tfsec:ignore:google-compute-enable-vpc-flow-logs
resource "google_compute_subnetwork" "itself" {
  count                    = var.turn_on == true ? length(var.subnet_cidr_range) : 0
  name                     = format("%s-subnet-%s", var.subnet_name_prefix, count.index)
  network                  = var.vpc_name
  ip_cidr_range            = element(var.subnet_cidr_range, count.index)
  private_ip_google_access = var.private_google_access
  description              = var.subnet_description
}


output "subnet_name" {
  value      = format("%s-subnet", var.subnet_name_prefix)
  depends_on = [google_compute_subnetwork.itself]
}

output "subnet_id" {
  value = google_compute_subnetwork.itself[*].id
}

output "subnet_gateway_address" {
  value = google_compute_subnetwork.itself[*].gateway_address
}

output "subnet_uri" {
  value = google_compute_subnetwork.itself[*].self_link
}
