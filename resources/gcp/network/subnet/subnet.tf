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

variable "subnet_cidr_range" {
  type        = string
  description = "Range of internal addresses that are owned by this subnetwork"
}

variable "private_google_access" {
  type        = bool
  default     = false
  description = "When enabled, VMs in this subnetwork without external IP addresses can access Google APIs"
}


resource "google_compute_subnetwork" "subnet" {
  name                     = format("%s-subnet", var.subnet_name_prefix)
  network                  = var.vpc_name
  ip_cidr_range            = var.subnet_cidr_range
  private_ip_google_access = var.private_google_access
  description              = var.subnet_description

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


output "subnet_name" {
  value      = format("%s-subnet", var.subnet_name_prefix)
  depends_on = [google_compute_subnetwork.subnet]
}

output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}

output "subnet_gateway_address" {
  value = google_compute_subnetwork.subnet.gateway_address
}

output "subnet_uri" {
  value = google_compute_subnetwork.subnet.self_link
}
