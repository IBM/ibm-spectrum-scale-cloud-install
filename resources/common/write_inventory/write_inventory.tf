/*
    Write provisioned infrastructure details to JSON.
*/

variable "write_inventory" {}
variable "clone_complete" {}
variable "inventory_path" {}
variable "cloud_platform" {}
variable "resource_prefix" {}
variable "vpc_region" {}
variable "vpc_availability_zones" {}
variable "scale_version" {}
variable "filesystem_block_size" {}
variable "compute_cluster_filesystem_mountpoint" {}
variable "compute_cluster_instance_ids" {}
variable "compute_cluster_instance_private_ips" {}
variable "compute_cluster_gui_username" {}
variable "compute_cluster_gui_password" {}
variable "storage_cluster_filesystem_mountpoint" {}
variable "storage_cluster_instance_ids" {}
variable "storage_cluster_instance_private_ips" {}
variable "storage_cluster_with_data_volume_mapping" {}
variable "storage_cluster_gui_username" {}
variable "storage_cluster_gui_password" {}
variable "storage_cluster_desc_instance_ids" {}
variable "storage_cluster_desc_instance_private_ips" {}
variable "storage_cluster_desc_data_volume_mapping" {}

resource "local_file" "itself" {
  count             = (tobool(var.clone_complete) == true && var.write_inventory == 1) ? 1 : 0
  sensitive_content = <<EOT
{
    "cloud_platform": ${var.cloud_platform},
    "resource_prefix": ${var.resource_prefix},
    "vpc_region": ${var.vpc_region},
    "vpc_availability_zones": ${var.vpc_availability_zones},
    "scale_version": ${var.scale_version},
    "compute_cluster_filesystem_mountpoint": ${var.compute_cluster_filesystem_mountpoint},
    "filesystem_block_size": ${var.filesystem_block_size},
    "compute_cluster_gui_username": ${var.compute_cluster_gui_username},
    "compute_cluster_gui_password": ${var.compute_cluster_gui_password},
    "compute_cluster_instance_ids": ${var.compute_cluster_instance_ids},
    "compute_cluster_instance_private_ips": ${var.compute_cluster_instance_private_ips},
    "storage_cluster_filesystem_mountpoint": ${var.storage_cluster_filesystem_mountpoint},
    "storage_cluster_instance_ids": ${var.storage_cluster_instance_ids},
    "storage_cluster_instance_private_ips": ${var.storage_cluster_instance_private_ips},
    "storage_cluster_with_data_volume_mapping": ${var.storage_cluster_with_data_volume_mapping},
    "storage_cluster_gui_username": ${var.storage_cluster_gui_username},
    "storage_cluster_gui_password": ${var.storage_cluster_gui_password},
    "storage_cluster_desc_instance_ids": ${var.storage_cluster_desc_instance_ids},
    "storage_cluster_desc_instance_private_ips": ${var.storage_cluster_desc_instance_private_ips},
    "storage_cluster_desc_data_volume_mapping": ${var.storage_cluster_desc_data_volume_mapping}
}
EOT
  filename          = var.inventory_path
}

output "write_inventory_complete" {
  value      = true
  depends_on = [local_file.itself]
}
