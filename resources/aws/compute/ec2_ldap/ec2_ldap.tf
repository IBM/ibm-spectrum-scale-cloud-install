/*
     Creates AWS EC2 OpenLDAP instance.
*/

variable "ami_id" {}
variable "dns_domain" {}
variable "forward_dns_zone" {}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "name_prefix" {}
variable "reverse_dns_domain" {}
variable "reverse_dns_zone" {}
variable "root_volume_type" {}
variable "security_groups" {}
variable "subnet_id" {}
variable "turn_on" {}
variable "user_public_key" {}

data "template_file" "user_data" {
  count    = var.turn_on ? 1 : 0
  template = <<EOF
#!/usr/bin/env bash
# Hostname settings
hostnamectl set-hostname --static "${var.name_prefix}.${var.dns_domain}"
echo 'preserve_hostname: True' > /etc/cloud/cloud.cfg.d/10_hostname.cfg
echo "${var.name_prefix}.${var.dns_domain}" > /etc/hostname
EOF
}

data "template_cloudinit_config" "user_data64" {
  count         = var.turn_on ? 1 : 0
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = try(data.template_file.user_data[0].rendered, null)
  }
}

resource "aws_instance" "itself" {
  count           = var.turn_on ? 1 : 0
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.user_public_key
  security_groups = var.security_groups
  subnet_id       = var.subnet_id

  # Only include iam_instance_profile if var.iam_instance_profile is a non-empty string
  # otherwise, skip the parameter entirely
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  root_block_device {
    encrypted             = true # TODO: Custom key
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  volume_tags = merge(
    {
      "Name" = format("%s-root", var.name_prefix)
    },
  )

  user_data_base64 = try(data.template_cloudinit_config.user_data64[0].rendered, null)
  tags = merge(
    {
      "Name" = var.name_prefix
    },
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
  count   = var.turn_on ? 1 : 0
  zone_id = var.forward_dns_zone
  type    = "A"
  name    = var.name_prefix
  records = [aws_instance.itself[0].private_ip, null]
  ttl     = 360
}

# Create "PTR" (Pointer) to enable reverse DNS lookup, from an IP address to a hostname
resource "aws_route53_record" "ptr_itself" {
  count   = var.turn_on ? 1 : 0
  zone_id = var.reverse_dns_zone
  type    = "PTR"
  name    = format("%s.%s.%s.%s", split(".", aws_instance.itself[0].private_ip)[3], split(".", aws_instance.itself[0].private_ip)[2], split(".", aws_instance.itself[0].private_ip)[1], var.reverse_dns_domain)
  records = [format("%s.%s", var.name_prefix, var.dns_domain)]
  ttl     = 360
}

output "instance_details" {
  value = aws_instance.itself[0].private_ip != null ? {
    private_ip = aws_instance.itself[0].private_ip
    id         = aws_instance.itself[0].id
    dns        = format("%s.%s", var.name_prefix, var.dns_domain)
    zone       = aws_instance.itself[0].availability_zone
  } : {}
}
