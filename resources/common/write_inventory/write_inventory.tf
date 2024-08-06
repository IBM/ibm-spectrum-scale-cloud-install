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
variable "bastion_user" {}
variable "bastion_instance_id" {}
variable "bastion_instance_public_ip" {}
variable "compute_cluster_instance_ids" {}
variable "compute_cluster_instance_private_ips" {}
variable "compute_cluster_instance_private_dns_ip_map" {}
variable "storage_cluster_filesystem_mountpoint" {}
variable "storage_cluster_instance_ids" {}
variable "storage_cluster_instance_private_ips" {}
variable "storage_cluster_with_data_volume_mapping" {}
variable "storage_cluster_instance_private_dns_ip_map" {}
variable "storage_cluster_desc_instance_ids" {}
variable "storage_cluster_desc_instance_private_ips" {}
variable "storage_cluster_desc_data_volume_mapping" {}
variable "storage_cluster_desc_instance_private_dns_ip_map" {}
variable "compute_cluster_instance_names" {}
variable "storage_cluster_instance_names" {}
variable "storage_subnet_cidr" {}
variable "compute_subnet_cidr" {}
variable "scale_remote_cluster_clustername" {}
variable "protocol_cluster_instance_names" {}
variable "client_cluster_instance_names" {}
variable "protocol_cluster_reserved_names" {}
variable "smb" {}
variable "nfs" {}
variable "interface" {}
variable "export_ip_pool" {}
variable "filesystem" {}
variable "mountpoint" {}
variable "object" {}
variable "protocol_gateway_ip" {}
variable "filesets" {}
variable "afm_cos_bucket_details" {}
variable "afm_config_details" {}
variable "afm_cluster_instance_names" {}

resource "local_sensitive_file" "itself" {
  count    = (tobool(var.clone_complete) == true && var.write_inventory == 1) ? 1 : 0
  content  = <<EOT
{
    "cloud_platform": ${var.cloud_platform},
    "resource_prefix": ${var.resource_prefix},
    "vpc_region": ${var.vpc_region},
    "vpc_availability_zones": ${var.vpc_availability_zones},
    "scale_version": ${var.scale_version},
    "compute_cluster_filesystem_mountpoint": ${var.compute_cluster_filesystem_mountpoint},
    "filesystem_block_size": ${var.filesystem_block_size},
    "bastion_user": ${var.bastion_user},
    "bastion_instance_id": ${var.bastion_instance_id},
    "bastion_instance_public_ip": ${var.bastion_instance_public_ip},
    "compute_cluster_instance_ids": ${var.compute_cluster_instance_ids},
    "compute_cluster_instance_private_ips": ${var.compute_cluster_instance_private_ips},
    "compute_cluster_instance_private_dns_ip_map": ${var.compute_cluster_instance_private_dns_ip_map},
    "storage_cluster_filesystem_mountpoint": ${var.storage_cluster_filesystem_mountpoint},
    "storage_cluster_instance_ids": ${var.storage_cluster_instance_ids},
    "storage_cluster_instance_private_ips": ${var.storage_cluster_instance_private_ips},
    "storage_cluster_with_data_volume_mapping": ${var.storage_cluster_with_data_volume_mapping},
    "storage_cluster_instance_private_dns_ip_map": ${var.storage_cluster_instance_private_dns_ip_map},
    "storage_cluster_desc_instance_ids": ${var.storage_cluster_desc_instance_ids},
    "storage_cluster_desc_instance_private_ips": ${var.storage_cluster_desc_instance_private_ips},
    "storage_cluster_desc_data_volume_mapping": ${var.storage_cluster_desc_data_volume_mapping},
    "storage_cluster_desc_instance_private_dns_ip_map": ${var.storage_cluster_desc_instance_private_dns_ip_map},
    "compute_cluster_instance_names": ${var.compute_cluster_instance_names},
    "storage_cluster_instance_names": ${var.storage_cluster_instance_names},
    "storage_subnet_cidr": ${var.storage_subnet_cidr},
    "compute_subnet_cidr": ${var.compute_subnet_cidr},
    "scale_remote_cluster_clustername": ${var.scale_remote_cluster_clustername},
    "protocol_cluster_instance_names": ${var.protocol_cluster_instance_names},
    "client_cluster_instance_names": ${var.client_cluster_instance_names},
    "protocol_cluster_reserved_names": ${var.protocol_cluster_reserved_names},
    "smb": ${var.smb},
    "nfs": ${var.nfs},
    "object": ${var.object},
    "interface": ${var.interface},
    "export_ip_pool": ${var.export_ip_pool},
    "filesystem": ${var.filesystem},
    "mountpoint": ${var.mountpoint},
    "protocol_gateway_ip": ${var.protocol_gateway_ip},
    "filesets": ${var.filesets},
    "afm_cos_bucket_details": ${var.afm_cos_bucket_details},
    "afm_config_details": ${var.afm_config_details},
    "afm_cluster_instance_names": ${var.afm_cluster_instance_names}

}
EOT
  filename = var.inventory_path
}

output "write_inventory_complete" {
  value      = true
  depends_on = [local_sensitive_file.itself]
}
