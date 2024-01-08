source "amazon-ebs" "itself" {
  vpc_id    = var.vpc_ref
  subnet_id = var.vpc_subnet_id
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  ami_description              = var.image_description
  ami_virtualization_type      = "hvm"
  ami_name                     = "${var.resource_prefix}-{{timestamp}}"
  instance_type                = var.instance_type
  region                       = var.vpc_region
  source_ami                   = var.source_image_reference
  security_group_id            = var.vpc_security_group_id
  associate_public_ip_address  = false
  communicator                 = "ssh"
  ssh_interface                = "private_ip"
  ssh_username                 = var.ssh_username
  ssh_port                     = var.ssh_port
  ssh_bastion_host             = var.ssh_bastion_host
  ssh_bastion_username         = var.ssh_bastion_username
  ssh_bastion_port             = var.ssh_bastion_port
  ssh_bastion_private_key_file = var.ssh_bastion_private_key_file
  ssh_clear_authorized_keys    = true
  ssh_timeout                  = 2m
  temporary_key_pair_name      = "amazon-packer-{{timestamp}}"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "IBM Spectrum Scale AMI"
  }
}
