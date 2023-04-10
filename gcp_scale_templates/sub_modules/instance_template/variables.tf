variable "project_id" {
  type        = string
  description = "GCP project ID to manage resources."
}

variable "vpc_region" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP region where the resources will be created."
}

variable "vpc_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "VPC id were to deploy the bastion."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "A list of availability zones names or ids in the region."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "GCP stack name, will be used for tagging resources."
}

variable "instances_ssh_user_name" {
  type        = string
  nullable    = true
  default     = null
  description = "Name of the administrator to access the bastion instance."
}

variable "compute_cluster_public_key_path" {
  type        = string
  nullable    = true
  default     = null
  description = "SSH public key local path for compute instances."
}

variable "storage_cluster_public_key_path" {
  type        = string
  nullable    = true
  default     = null
  description = "SSH public key local path for storage instances."
}

variable "credential_json_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of IDs of storage cluster private subnets."
}

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of IDs of compute cluster private subnets."
}

variable "total_compute_cluster_instances" {
  type        = number
  nullable    = true
  default     = null
  description = "Number of GCP instances to be launched for compute cluster."
}

variable "compute_cluster_instance_type" {
  type        = string
  nullable    = true
  default     = null
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "compute_boot_disk_size" {
  type        = number
  nullable    = true
  default     = null
  description = "Compute instances boot disk size in gigabytes."
}

variable "compute_boot_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "compute_boot_image" {
  type        = string
  nullable    = true
  default     = null
  description = "Image from which to initialize Spectrum Scale compute instances."
}

variable "compute_instance_tags" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of tags to attach to the compute instance."
}

variable "total_storage_cluster_instances" {
  type        = number
  nullable    = true
  default     = null
  description = "Number of instances to be launched for storage instances."
}

variable "block_devices_per_storage_instance" {
  type        = number
  nullable    = true
  default     = 0
  description = "Number of data disks to be attached to each storage instance."
}

variable "scratch_devices_per_storage_instance" {
  type        = number
  nullable    = true
  default     = 0
  description = "Number of scratch disks to be attached to each storage instance."
}

variable "storage_instance_tags" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of tags to attach to the compute instance."
}

variable "storage_cluster_instance_type" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP instance machine type to create Spectrum Scale storage instances."
}

variable "storage_boot_disk_size" {
  type        = number
  nullable    = true
  default     = null
  description = "Storage instances boot disk size in gigabytes."
}

variable "storage_boot_disk_type" {
  type        = string
  nullable    = true
  default     = null
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "storage_cluster_image_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "Image from which to initialize Spectrum Scale storage instances."
}

variable "block_device_volume_type" {
  nullable    = true
  default     = null
  description = "GCE disk type (valid: pd-standard, pd-ssd , local-ssd)."
}

variable "block_device_volume_size" {
  type        = string
  nullable    = true
  default     = null
  description = "Data disk size in gigabytes."
}

variable "service_email" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP service account e-mail address."
}

variable "scopes" {
  type        = list(string)
  default     = ["cloud-platform"]
  description = "List of service scopes."
}

variable "storage_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "Range of storage cidr."
}

variable "compute_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "Range of storage cidr."
}

variable "bastion_instance_tags" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of tags to attach to the bastion instance."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  nullable    = true
  default     = null
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "create_remote_mount_cluster" {
  type        = bool
  nullable    = true
  default     = null
  description = "Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup."
}

variable "spectrumscale_rpms_path" {
  type        = string
  nullable    = true
  default     = null
  description = "Path that contains IBM Spectrum Scale product cloud rpms."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  nullable    = true
  default     = null
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "bastion_instance_id" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion instance id."
}

variable "bastion_user" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion login username."
}

variable "bastion_instance_public_ip" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion instance public ip address."
}

variable "storage_cluster_filesystem_mountpoint" {
  type        = string
  nullable    = true
  default     = null
  description = "Storage cluster (owningCluster) Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  nullable    = true
  default     = null
  description = "Filesystem block size."
}

variable "create_scale_cluster" {
  type        = bool
  nullable    = true
  default     = null
  description = "Flag to represent whether to create scale cluster or not."
}

variable "inventory_format" {
  type        = string
  default     = "json"
  description = "Specify inventory format suited for ansible playbooks."
}

variable "using_packer_image" {
  type        = bool
  nullable    = true
  default     = true
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "using_direct_connection" {
  type        = bool
  nullable    = true
  default     = null
  description = "If true, will skip the jump/bastion host configuration."
}

variable "storage_cluster_gui_username" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_gui_password" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "Password for Storage cluster GUI"
}

variable "bastion_ssh_private_key" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion SSH private key path, which will be used to login to bastion host."
}
