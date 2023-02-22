source "amazon-ebs" "itself" {
  vpc_id                      = var.vpc_id
  subnet_id                   = var.vpc_subnet_id
  associate_public_ip_address = true
  security_group_id           = var.vpc_security_group_id
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  ami_description           = var.image_description
  ami_virtualization_type   = "hvm"
  ami_name                  = "${var.resource_prefix}-{{timestamp}}"
  instance_type             = var.instance_type
  region                    = var.vpc_region
  source_ami                = var.source_image_reference
  ssh_username              = "ec2-user"
  ssh_clear_authorized_keys = true
  temporary_key_pair_name   = "amazon-packer-{{timestamp}}"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "IBM Spectrum Scale AMI"
  }
}
