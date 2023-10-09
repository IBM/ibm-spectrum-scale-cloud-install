/*
  Bastion/Jumphost instance
   - creates firewall required for bastion instance
   - launch bastion instance
*/

locals {
  security_rule_description_bastion_external_ingress = ["Allow ICMP traffic from external cidr to bastion instances",
  "Allow SSH traffic from external cidr to bastion instances"]

  bastion_network_tag = format("%s-bastion-external", var.resource_prefix)
}

# Allow traffic from external cidr block to bastion instances
module "allow_traffic_from_external_cidr_to_bastion" {
  source               = "../../../resources/gcp/security/security_rule_target_tags"
  turn_on              = true
  firewall_name_prefix = format("%s-bastion-ingress", var.resource_prefix)
  firewall_description = local.security_rule_description_bastion_external_ingress
  vpc_ref              = var.vpc_ref
  source_ranges        = var.remote_cidr_blocks
  protocols            = ["icmp", "TCP"]
  ports                = [-1, var.bastion_public_ssh_port]
  target_tags          = [local.bastion_network_tag]
}

# Creates bastion instance template
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
  network_tags                = [local.bastion_network_tag]
}

# launch bastion instance
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
