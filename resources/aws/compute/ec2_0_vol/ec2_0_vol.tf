/*
     Creates specified number of AWS EC2 instance(s).
 */

variable "name_prefix" {}
variable "instances_count" {}
variable "ami_id" {}
variable "instance_type" {}
variable "security_groups" {}
variable "iam_instance_profile" {}
variable "placement_group" {}
variable "subnet_ids" {}
variable "root_volume_type" {}
variable "user_public_key" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "volume_tags" {}
variable "tags" {}

data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
if grep -q "Red Hat" /etc/os-release
then
    yum install -y python3 kernel-devel-$(uname -r) kernel-headers-$(uname -r)
fi
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

resource "aws_instance" "itself" {
  count                = var.instances_count
  ami                  = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.user_public_key
  security_groups      = var.security_groups
  subnet_id            = element(var.subnet_ids, count.index)
  iam_instance_profile = var.iam_instance_profile
  placement_group      = var.placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  volume_tags = merge(
    {
      "Name" = format("%s-root-%s", var.name_prefix, count.index + 1)
    },
    var.volume_tags,
  )

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags = merge(
    {
      "Name" = format("%s-%s", var.name_prefix, count.index + 1)
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

output "instance_private_ips" {
  value = aws_instance.itself.*.private_ip
}

output "instance_ids" {
  value = aws_instance.itself.*.id
}
