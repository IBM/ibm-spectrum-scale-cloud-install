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

variable "resource_group" {
  type        = string
  description = "IBM Cloud resource group name."
}

variable "vpc_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/18", "10.241.64.0/18", "10.241.128.0/18"]
  description = "IBM Cloud VPC address prefixes."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.1.0/24", "10.241.64.1/24", "10.241.128.1/24"]
  description = "List of cidr_blocks of storage cluster private subnets."
}

variable "vpc_create_separate_subnets" {
  type        = bool
  default     = true
  description = "Flag to select if separate private subnet to be created for compute cluster."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.0.0/24"]
  description = "List of cidr_blocks of compute private subnets."
}

variable "bastion_key_pair" {
  type        = string
  description = "The key pair to use to launch the bastion host."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDRs that can access to the bastion. Default : 0.0.0.0/0"
}

variable "bastion_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-20-04-2-minimal-amd64-1"
  description = "Bastion OS image name."
}

variable "bastion_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for Bastion virtual server instance."
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

variable "bastion_ssh_private_key" {
  type        = string
  default     = null
  description = "Bastion SSH private key path, which will be used to login to bastion host."
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
