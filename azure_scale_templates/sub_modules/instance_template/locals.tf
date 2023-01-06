/*
  Local variables for the instance module.
*/
locals {
  cluster_type = (
    (var.vnet_storage_cluster_private_subnets != null && var.vnet_compute_cluster_private_subnets == null) ? "storage" :
    (var.vnet_storage_cluster_private_subnets == null && var.vnet_compute_cluster_private_subnets != null) ? "compute" :
    (var.vnet_storage_cluster_private_subnets != null && var.vnet_compute_cluster_private_subnets != null) ? "combined" : "none"
  )
  data_disk_device_names = ["/dev/sdc", "/dev/sdd", "/dev/sde", "/dev/sdf", "/dev/sdg", "/dev/sdh", "/dev/sdi", "/dev/sdj", "/dev/sdk"]
  gpfs_base_rpm_path     = var.spectrumscale_rpms_path != null ? fileset(var.spectrumscale_rpms_path, "gpfs.base-*") : null
  scale_version          = local.gpfs_base_rpm_path != null ? regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0] : null
}
