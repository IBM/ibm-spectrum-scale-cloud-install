source "amazon-ebs" "itself" {
  vpc_id            = var.vpc_id
  security_group_id = var.vpc_security_group_id
  ami_block_device_mappings {
    device_name = "/dev/xvda"
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  ami_description           = var.ami_description
  ami_virtualization_type   = "hvm"
  ami_name                  = "${var.ami_name}-{{timestamp}}"
  instance_type             = var.instance_type
  region                    = var.vpc_region
  source_ami                = var.source_ami_id
  ssh_username              = "ec2-user"
  ssh_clear_authorized_keys = true
  temporary_key_pair_name   = "amazon-packer-{{timestamp}}"

  temporary_iam_instance_profile_policy_document {
    Statement {
      Action   = ["s3:*"]
      Effect   = "Allow"
      Resource = ["*"]
    }
    Version = "2012-10-17"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "IBM Spectrum Scale AMI"
  }
}
