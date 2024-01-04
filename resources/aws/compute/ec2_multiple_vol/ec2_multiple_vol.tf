/*
     Creates specified number of AWS EC2 instance(s).
*/

variable "zone" {}
variable "name_prefix" {}
variable "ami_id" {}
variable "instance_type" {}
variable "security_groups" {}
variable "iam_instance_profile" {}
variable "placement_group" {}
variable "subnet_id" {}
variable "root_volume_type" {}
variable "user_public_key" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "ebs_optimized" {}
variable "disks" {}
variable "ebs_block_device_delete_on_termination" {}
variable "ebs_block_device_encrypted" {}
variable "ebs_block_device_kms_key_id" {}
variable "is_nitro_instance" {}
variable "tags" {}
variable "volume_tags" {}

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

data "template_file" "nvme_alias" {
  count    = tobool(var.is_nitro_instance) == true ? 1 : 0
  template = file("${path.module}/scripts/nvme_alias.sh.tpl")
}

data "template_cloudinit_config" "nvme_user_data64" {
  count         = tobool(var.is_nitro_instance) == true ? 1 : 0
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
  }
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.nvme_alias[0].rendered
  }
}

data "aws_kms_key" "itself" {
  count  = var.ebs_block_device_kms_key_id != null ? 1 : 0
  key_id = var.ebs_block_device_kms_key_id
}

# Create the EC2 instance
resource "aws_instance" "itself" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.user_public_key
  security_groups = var.security_groups
  subnet_id       = var.subnet_id

  # Only include iam_instance_profile if var.iam_instance_profile is a non-empty string
  # otherwise, skip the parameter entirely
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  placement_group = var.placement_group
  ebs_optimized   = tobool(var.ebs_optimized)

  root_block_device {
    encrypted             = var.ebs_block_device_encrypted == false ? null : true
    kms_key_id            = try(data.aws_kms_key.itself[0].key_id, null)
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  user_data_base64 = tobool(var.is_nitro_instance) == true ? data.template_cloudinit_config.nvme_user_data64[0].rendered : data.template_cloudinit_config.user_data64.rendered
  tags             = merge({ "Name" = var.name_prefix }, var.tags)

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    ignore_changes = all
  }
}

# Create the specified volumes with the corresponding types and size
resource "aws_ebs_volume" "itself" {
  for_each          = var.disks
  availability_zone = var.zone
  size              = each.value["size"]
  type              = each.value["type"]
  iops              = each.value["iops"]
  throughput        = each.value["throughput"]
  encrypted         = var.ebs_block_device_encrypted
  kms_key_id        = var.ebs_block_device_kms_key_id
  tags = merge(
    {
      "Name" = each.key
    },
    var.volume_tags,
  )
}

# Attach the volumes to provisioned instance
resource "aws_volume_attachment" "itself" {
  for_each     = aws_ebs_volume.itself
  device_name  = var.disks[each.key]["device_name"]
  volume_id    = aws_ebs_volume.itself[each.key].id
  instance_id  = aws_instance.itself.id
  skip_destroy = var.ebs_block_device_delete_on_termination
}

output "instance_private_ips" {
  value = aws_instance.itself.private_ip
}

output "instance_ids" {
  value = aws_instance.itself.id
}

output "instance_private_dns_name" {
  value = aws_instance.itself.private_dns
}
