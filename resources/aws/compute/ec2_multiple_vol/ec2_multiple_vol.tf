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
variable "ebs_optimized" {}
variable "ebs_block_devices" {}
variable "ebs_block_device_names" {}
variable "ebs_block_device_delete_on_termination" {}
variable "ebs_block_device_encrypted" {}
variable "ebs_block_device_kms_key_id" {}
variable "ebs_block_device_volume_size" {}
variable "ebs_block_device_volume_type" {}
variable "ebs_block_device_iops" {}
variable "ebs_block_device_throughput" {}
variable "enable_instance_store_block_device" {}
variable "enable_nvme_block_device" {}
variable "nvme_block_device_count" {}
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

data "template_file" "nvme_alias" {
  count    = tobool(var.enable_nvme_block_device) == true ? 1 : 0
  template = file("${path.module}/scripts/nvme_alias.sh.tpl")
}

data "template_cloudinit_config" "nvme_user_data64" {
  count         = tobool(var.enable_nvme_block_device) == true ? 1 : 0
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

resource "null_resource" "ebs_mappings" {
  count = var.instances_count > 0 ? var.ebs_block_devices : 0

  triggers = {
    delete_on_termination = var.ebs_block_device_delete_on_termination
    device_name           = element(var.ebs_block_device_names, count.index)
    encrypted             = var.ebs_block_device_encrypted == false ? null : true
    iops                  = var.ebs_block_device_iops
    throughput            = var.ebs_block_device_throughput
    kms_key_id            = var.ebs_block_device_kms_key_id
    volume_size           = var.ebs_block_device_volume_size
    volume_type           = var.ebs_block_device_volume_type
  }
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
  iam_instance_profile = var.iam_instance_profile
  placement_group      = var.placement_group
  ebs_optimized        = tobool(var.ebs_optimized)

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  dynamic "ebs_block_device" {
    for_each = null_resource.ebs_mappings.*.triggers
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }

  volume_tags = merge(
    {
      "Name" = format("%s-%s", var.name_prefix, each.value.sequence_string)
    },
    var.volume_tags,
  )

  user_data_base64 = tobool(var.enable_nvme_block_device) == true ? data.template_cloudinit_config.nvme_user_data64[0].rendered : data.template_cloudinit_config.user_data64.rendered
  tags             = merge({ "Name" = format("%s-%s", var.name_prefix, each.value.sequence_string) }, var.tags)

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

output "instance_ips_with_ebs_mapping" {
  value = tobool(var.enable_nvme_block_device) == true || tobool(var.enable_instance_store_block_device) == true ? try({ for instance_details in aws_instance.itself : instance_details.private_ip => slice(var.ebs_block_device_names, 0, var.nvme_block_device_count) }, {}) : try({ for instance_details in aws_instance.itself : instance_details.private_ip => slice(var.ebs_block_device_names, 0, var.ebs_block_devices) }, {})
}

output "instance_private_dns_ip_map" {
  value = try({ for instance_details in aws_instance.itself : instance_details.private_ip => instance_details.private_dns }, {})
}

