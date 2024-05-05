/*
     Creates AWS EC2 instance(s).
*/

variable "ami_id" {}
variable "dns_domain" {}
variable "forward_dns_zone" {}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "name_prefix" {}
variable "placement_group" {}
variable "reverse_dns_domain" {}
variable "reverse_dns_zone" {}
variable "root_device_encrypted" {}
variable "root_device_kms_key_id" {}
variable "root_volume_type" {}
variable "secondary_private_ip" {}
variable "security_groups" {}
variable "subnet_id" {}
variable "tags" {}
variable "user_public_key" {}
variable "volume_tags" {}

data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
# Hostname settings
hostnamectl set-hostname --static "${var.name_prefix}.${var.dns_domain}"
echo 'preserve_hostname: True' > /etc/cloud/cloud.cfg.d/10_hostname.cfg
echo "${var.name_prefix}.${var.dns_domain}" > /etc/hostname
EOF
}

data "template_cloudinit_config" "user_data64" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
  }
}

data "aws_kms_key" "itself" {
  count  = var.root_device_kms_key_id != null ? 1 : 0
  key_id = var.root_device_kms_key_id
}

resource "aws_instance" "itself" {
  ami                   = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.user_public_key
  security_groups       = var.security_groups
  subnet_id             = var.subnet_id
  secondary_private_ips = var.secondary_private_ip != null ? [var.secondary_private_ip] : null

  # Only include iam_instance_profile if var.iam_instance_profile is a non-empty string
  # otherwise, skip the parameter entirely
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  placement_group = var.placement_group

  root_block_device {
    encrypted             = var.root_device_encrypted == false ? null : true
    kms_key_id            = try(data.aws_kms_key.itself[0].key_id, null)
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  volume_tags = merge(
    {
      "Name" = format("%s-root", var.name_prefix)
    },
    var.volume_tags,
  )

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags = merge(
    {
      "Name" = var.name_prefix
    },
    var.tags,
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    ignore_changes = all
  }
}

# Create "A" (IPv4 Address) record to map IPv4 address as hostname along with domain
resource "aws_route53_record" "a_itself" {
  zone_id = var.forward_dns_zone
  type    = "A"
  name    = var.name_prefix
  records = [aws_instance.itself.private_ip]
  ttl     = 360
}

# Create "PTR" (Pointer) to enables reverse DNS lookup, from an IP address to a hostname
resource "aws_route53_record" "ptr_itself" {
  zone_id = var.reverse_dns_zone
  type    = "PTR"
  name    = format("%s.%s.%s.%s", split(".", aws_instance.itself.private_ip)[3], split(".", aws_instance.itself.private_ip)[2], split(".", aws_instance.itself.private_ip)[1], var.reverse_dns_domain)
  records = [format("%s.%s", var.name_prefix, var.dns_domain)]
  ttl     = 360
}

# Create "A" (IPv4 Address) record to map CES IPv4 address as hostname along with domain
resource "aws_route53_record" "ces_a_itself" {
  count   = var.secondary_private_ip != null ? 1 : 0
  zone_id = var.forward_dns_zone
  type    = "A"
  name    = format("%s-ces", var.name_prefix)
  records = [var.secondary_private_ip]
  ttl     = 360
}

# Create "PTR" (Pointer) to enables reverse DNS lookup, from an IP address to a hostname for CES node
resource "aws_route53_record" "ces_ptr_itself" {
  zone_id = var.reverse_dns_zone
  type    = "PTR"
  name    = format("%s.%s.%s.%s", split(".", var.secondary_private_ip)[3], split(".", var.secondary_private_ip)[2], split(".", var.secondary_private_ip)[1], var.reverse_dns_domain)
  records = [format("%s-ces.%s", var.name_prefix, var.dns_domain)]
  ttl     = 360
}

output "instance_details" {
  value = {
    private_ip = aws_instance.itself.private_ip
    id         = aws_instance.itself.id
    dns        = format("%s.%s", var.name_prefix, var.dns_domain)
    zone       = aws_instance.itself.availability_zone
  }
}
