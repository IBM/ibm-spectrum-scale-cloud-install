variable "asg_name_prefix" {}
variable "vpc_zone" {}
variable "asg_desired_size" {}
variable "instance_template" {}

// Note: google_compute_region_instance_group_manager can be used to balance the instances across
// availability zones, but lacks data block to fetch the instances. Hence using google_compute_instance_group_manager
// which spreads within a single zone
resource "google_compute_instance_group_manager" "itself" {
  name               = var.asg_name_prefix
  base_instance_name = var.asg_name_prefix
  version {
    instance_template = var.instance_template
  }
  zone = var.vpc_zone

  target_size = var.asg_desired_size
  wait_for_instances = true
}

data "google_compute_instance_group" "cig_data" {
  name = resource.google_compute_instance_group_manager.itself.name
  zone = var.vpc_zone
}

output "instances" {
  value       = tolist(data.google_compute_instance_group.cig_data.instances)
  description = "Instance names."
}
