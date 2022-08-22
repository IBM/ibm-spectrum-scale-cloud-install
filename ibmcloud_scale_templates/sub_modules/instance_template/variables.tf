variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "A list of availability zones names or ids in the region."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud resource group id."
}

variable "vpc_id" {
  type        = string
  description = "VPC id were to deploy the bastion."
}

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  description = "List of IDs of compute cluster private subnets."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  description = "List of IDs of storage cluster private subnets."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 3
  description = "Number of instances to be launched for compute cluster."
}

variable "compute_cluster_key_pair" {
  type        = string
  description = "The key pair to use to launch the compute cluster host."
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the compute cluster instances."
}

variable "compute_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for compute cluster virtual server instance."
}

variable "using_rest_api_remote_mount" {
  type        = string
  default     = true
  description = "If false, skips GUI initialization on compute cluster for remote mount configuration."
}

variable "compute_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for compute cluster GUI"
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 4
  description = "Number of instances to be launched for storage cluster."
}

variable "storage_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the storage cluster instances."
}

variable "storage_vsi_profile" {
  type        = string
  default     = "bx2d-8x32"
  description = "Profile to be used for storage cluster virtual server instance."
}

variable "storage_cluster_key_pair" {
  type        = string
  description = "The key pair to use to launch the storage cluster host."
}

variable "storage_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for storage cluster GUI"
}

variable "using_packer_image" {
  type        = bool
  default     = false
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "using_direct_connection" {
  type        = bool
  default     = false
  description = "If true, will skip the jump/bastion host configuration."
}

variable "vpc_compute_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS service resource id."
}

variable "vpc_storage_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud storage cluster DNS service resource id."
}

variable "vpc_compute_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS zone id."
}

variable "vpc_storage_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud storage cluster DNS zone id."
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = "compscale.com"
  description = "IBM Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  default     = "strgscale.com"
  description = "IBM Cloud DNS domain name to be used for storage cluster."
}

variable "vpc_custom_resolver_id" {
  type        = string
  description = "IBM Cloud DNS custom resolver id."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  default     = "/opt/IBM/ibm-spectrumscale-cloud-deploy"
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "spectrumscale_rpms_path" {
  type        = string
  default     = "/opt/IBM/gpfs_cloud_rpms"
  description = "Path that contains IBM Spectrum Scale product cloud rpms."
}

variable "storage_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Storage cluster (owningCluster) Filesystem mount point."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "Filesystem block size."
}

variable "create_separate_namespaces" {
  type        = bool
  default     = true
  description = "Flag to select if separate namespace needs to be created for compute instances."
}

variable "bastion_instance_public_ip" {
  type        = string
  default     = null
  description = "Bastion instance public ip address."
}

variable "bastion_security_group_id" {
  type        = string
  default     = null
  description = "Bastion security group id."
}

variable "bastion_instance_id" {
  type        = string
  default     = null
  description = "Bastion instance id."
}

variable "bastion_ssh_private_key" {
  type        = string
  default     = null
  description = "Bastion SSH private key path, which will be used to login to bastion host."
}

variable "deploy_controller_sec_group_id" {
  type        = string
  default     = null
  description = "Deployment controller security group id. Default: null"
}

variable "vpc_create_activity_tracker" {
  type        = bool
  default     = true
  description = "Flag to select if IBM Cloud activity tracker to be created or not. Note: You can only provision 1 instance of this service per IBM Cloud region."
}

variable "activity_tracker_plan_type" {
  type        = string
  default     = "lite"
  description = "IBM Cloud activity tracker plan type (Valid: lite, 7-day, 14-day, 30-day, hipaa-30-day)."
}

variable "create_scale_cluster" {
  type        = bool
  default     = false
  description = "Flag to represent whether to create scale cluster or not."
}

variable "scale_cluster_resource_tags" {
  type        = list(string)
  default     = null
  description = "A list of tags for resources created for scale cluster."
}

variable "compute_vsi_osimage_id" {
  type = string
  default = ""
  description = "Image id to use for provisioning the compute cluster instances."
}

variable "storage_vsi_osimage_id" {
  type = string
  default = ""
  description = "Image id to use for provisioning the storage cluster instances."
}

variable "storage_bare_metal_server_profile" {
  type = string
  default = "cx2d-metal-96x192"
  description = "Specify the virtual server instance profile type name to be used to create the Baremetal Storage nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-bare-metal-servers-profile&interface=ui)."
}

variable "storage_bare_metal_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the storage cluster instances."
}

variable "storage_bare_metal_osimage_id" {
  type        = string
  default     = ""
  description = "Image ID to use for provisioning the storage cluster instances."
}

variable "storage_type" {
  type        = string
  default     = "scratch"
  description = "Select the required scale filesystem deployment method. Note: Choosing the scale scratch type will deploy scale filesystem on VSI and scale persistent type will deploy scale filesystem on Baremetal server."
}
