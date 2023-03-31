/*
  Create a new Bastion instance
*/

module "bastion_firewall" {
  source               = "../../../resources/gcp/network/firewall/allow_bastion/"
  source_range         = var.remote_cidr_blocks
  firewall_name_prefix = var.resource_prefix
  traffic_port         = var.bastion_public_ssh_port
  vpc_name             = var.vpc_ref
}

module "bastion_autoscaling_launch_template" {
  source                      = "../../../resources/gcp/asg/launch_template"
  launch_template_name_prefix = format("%s-%s", var.resource_prefix, "bastion-launch-tmpl")
  image_id                    = var.bastion_image_ref
  boot_disk_size              = var.bastion_boot_disk_size
  boot_disk_type              = var.bastion_boot_disk_type
  instance_type               = var.bastion_instance_type
  subnetwork_name             = var.vpc_auto_scaling_group_subnets[0]
  network_tier                = var.bastion_network_tier
  ssh_user_name               = var.bastion_ssh_user_name
  ssh_key_path                = var.bastion_ssh_key_path
}

module "bastion_autoscaling_group" {
  source            = "../../../resources/gcp/asg/asg_group"
  asg_name_prefix   = format("%s-%s", var.resource_prefix, "bastion-asg")
  vpc_zone          = var.vpc_availability_zones[0]
  asg_desired_size  = var.desired_instance_count
  instance_template = module.bastion_autoscaling_launch_template.asg_launch_template_self_link
}

# Note: module.bastion_autoscaling_group.instances returns instances url which is not vaild to use neither
# as instance id nor as instance name. Hence needed to apply trimsuffix operation to extract instance name
data "google_compute_instance" "itself" {
  count      = var.desired_instance_count
  name       = ([for instance in module.bastion_autoscaling_group.instances : trimsuffix(element(split("/", instance), 10), "\"")])[count.index]
  zone       = var.vpc_availability_zones[0]
  depends_on = [module.bastion_autoscaling_group]
}
