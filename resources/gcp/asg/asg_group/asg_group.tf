variable "asg_name_prefix" {}
variable "vpc_zone" {}
variable "asg_desired_size" {}
variable "instance_template" {}

resource "google_compute_instance_group_manager" "itself" {
  name               = var.asg_name_prefix
  base_instance_name = var.asg_name_prefix
  version {
    instance_template = var.instance_template
  }
  zone = var.vpc_zone

  target_size = var.asg_desired_size
}
