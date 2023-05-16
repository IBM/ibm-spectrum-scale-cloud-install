/*
  Bastion/Jumphost instance
   - creates firewall required for bastion instance
   - launch bastion instance
*/

locals {
  security_rule_description_bastion_external_ingress = ["Allow ICMP traffic from external cidr to bastion instances",
  "Allow SSH traffic from external cidr to bastion instances"]

  security_rule_description_bastion_internal_ingress = ["Allow ICMP traffic within bastion instances",
  "Allow SSH traffic within bastion instances"]

  security_rule_description_bastion_egress_all = ["Allow egress from bastion instances"]

  traffic_protocol_cluster_bastion_scale_ingress = ["icmp", "TCP"]
  traffic_port_cluster_bastion_scale_ingress     = [-1, 22]
}

# Allow traffic from external cidr block to bastion instances
module "allow_traffic_from_external_cidr_to_bastion" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress      = true
  firewall_name_prefix = "${var.resource_prefix}-bastion-external"
  vpc_ref              = var.vpc_ref
  source_ranges        = var.remote_cidr_blocks
  protocol             = local.traffic_protocol_cluster_bastion_scale_ingress
  ports                = local.traffic_port_cluster_bastion_scale_ingress
  firewall_description = local.security_rule_description_bastion_external_ingress
}

data "google_compute_subnetwork" "public_bastion_cluster" {
  count     = var.vpc_auto_scaling_group_subnets != null ? 1 : 0
  self_link = length(regexall("^https", var.vpc_auto_scaling_group_subnets[0])) > 0 ? var.vpc_auto_scaling_group_subnets[0] : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.vpc_region}/subnetworks/${var.vpc_auto_scaling_group_subnets[0]}"
}

# Allow traffic bastion internals
module "allow_traffic_scale_cluster_bastion_internals" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress_bi   = true
  firewall_name_prefix = "${var.resource_prefix}-bastion-internal"
  vpc_ref              = var.vpc_ref
  source_ranges        = length(data.google_compute_subnetwork.public_bastion_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.public_bastion_cluster[*].ip_cidr_range : null
  destination_ranges   = length(data.google_compute_subnetwork.public_bastion_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.public_bastion_cluster[*].ip_cidr_range : null
  protocol             = local.traffic_protocol_cluster_bastion_scale_ingress
  ports                = local.traffic_port_cluster_bastion_scale_ingress
  firewall_description = local.security_rule_description_bastion_internal_ingress
}

# Allow bastion egress traffic
module "allow_traffic_scale_cluster_egress_all" {
  source                       = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_egress               = true
  firewall_name_prefix         = "${var.resource_prefix}-bastion"
  vpc_ref                      = var.vpc_ref
  destination_range_egress_all = ["0.0.0.0/0"]
  firewall_description         = local.security_rule_description_bastion_egress_all
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
