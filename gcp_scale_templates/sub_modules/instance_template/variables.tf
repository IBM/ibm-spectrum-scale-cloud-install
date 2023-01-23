variable "gcp_project_id" {
  type        = string
  description = "GCP project ID to manage resources."
}

variable "vpc_region" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP region where the resources will be created."
}

variable "vpc_name" {
  type        = string
  default     = "spectrum-scale-vpc"
  description = "GCP VPC name."
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
  default     = "gcpadmin"
  description = "Name of the administrator to access the bastion instance."
}

variable "compute_cluster_public_key_path" {
  type        = string
  description = "SSH public key local path for compute instances."
}

variable "storage_cluster_public_key_path" {
  type        = string
  description = "SSH public key local path for storage instances."
}

variable "credentials_file_path" {
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
  default     = []
  description = "List of IDs of compute cluster private subnets."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for compute instances."
}

variable "compute_machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create Spectrum Scale compute instances."
}

variable "compute_instance_name_prefix" {
  type        = string
  default     = "compute-scale"
  description = "Compute instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "compute_boot_disk_size" {
  type        = number
  default     = 100
  description = "Compute instances boot disk size in gigabytes."
}

variable "compute_boot_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "compute_boot_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
  description = "Image from which to initialize Spectrum Scale compute instances."
}

variable "compute_instance_tags" {
  type        = list(string)
  default     = ["spectrum-scale-compute-cluster"]
  description = "List of tags to attach to the compute instance."
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for storage instances."
}

variable "data_disks_per_instance" {
  type        = number
  default     = 1
  description = "Number of data disks to be attached to each storage instance."
}

variable "storage_instance_name_prefix" {
  type        = string
  default     = "storage-scale"
  description = "Storage instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "storage_instance_tags" {
  type        = list(string)
  default     = ["spectrum-scale-storage-cluster"]
  description = "List of tags to attach to the compute instance."
}

variable "storage_machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create Spectrum Scale storage instances."
}

variable "storage_boot_disk_size" {
  type        = number
  default     = 100
  description = "Storage instances boot disk size in gigabytes."
}

variable "storage_boot_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "storage_boot_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
  description = "Image from which to initialize Spectrum Scale storage instances."
}

variable "data_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd , local-ssd)."
}

variable "data_disk_size" {
  type        = string
  default     = 500
  description = "Data disk size in gigabytes."
}

variable "operator_email" {
  type        = string
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
  default     = ["spectrum-scale-bastion"]
  description = "List of tags to attach to the bastion instance."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  nullable    = true
  default     = "/tmp/"
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
