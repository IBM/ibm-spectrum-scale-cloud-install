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
variable "root_volume_encrypted" {}
variable "root_volume_kms_key_id" {}
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
  count  = var.root_volume_kms_key_id != null ? 1 : 0
  key_id = var.root_volume_kms_key_id
}

resource "aws_instance" "itself" {
  for_each = {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.instances_count + 1) : idx => {
      sequence_string = tostring(count_number)
      subnet_id       = element(var.subnet_ids, idx)
    }
  }

  ami                  = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.user_public_key
  security_groups      = var.security_groups
  subnet_id            = each.value.subnet_id
  iam_instance_profile = var.iam_instance_profile != null ? var.iam_instance_profile : null
  placement_group      = var.placement_group

  root_block_device {
    encrypted             = var.root_volume_encrypted == false ? null : true
    kms_key_id            = try(data.aws_kms_key.itself[0].key_id, null)
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  volume_tags = merge(
    {
      "Name" = format("%s-root-%s", var.name_prefix, each.value.sequence_string)
    },
    var.volume_tags,
  )

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags = merge(
    {
      "Name" = format("%s-%s", var.name_prefix, each.value.sequence_string)
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
  value = try(toset([for instance_details in aws_instance.itself : instance_details.private_ip]), [])
}

output "instance_ids" {
  value = try(toset([for instance_details in aws_instance.itself : instance_details.id]), [])
}

output "instance_private_dns_ip_map" {
  value = try({ for instance_details in aws_instance.itself : instance_details.private_ip => instance_details.private_dns }, {})
}
