source "ibmcloud-vpc" "itself" {
  api_key                      = var.ibm_api_key
  region                       = var.vpc_region
  subnet_id                    = var.vpc_subnet_id
  resource_group_name          = var.resource_group_name
  vsi_base_image_id            = var.source_image_reference
  vsi_profile                  = "bx2-2x8"
  vsi_interface                = "private"
  image_name                   = "${var.resource_prefix}-{{timestamp}}"
  communicator                 = "ssh"
  ssh_port                     = 22
  ssh_bastion_host             = var.ssh_bastion_host
  ssh_bastion_username         = var.ssh_bastion_username
  ssh_bastion_port             = var.ssh_bastion_port
  ssh_bastion_private_key_file = var.ssh_bastion_private_key_file
  ssh_username                 = var.ssh_username
  timeout                      = "25m"
}
