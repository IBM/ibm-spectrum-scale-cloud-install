variable "region" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "GCP region where the resources will be created."
}

variable "zones" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = list(string)
  description = "GCP zones that the instances should be created."
}

variable "stack_name" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  default     = "spectrum-scale"
  description = "GCP stack name, will be used for tagging resources."
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID to manage resources."
}

variable "credentials_file_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "vpc_routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "Network-wide routing mode to use (valid: REGIONAL, GLOBAL)."
}

variable "vpc_description" {
  type        = string
  default     = "This VPC is used by IBM Spectrum Scale"
  description = "Description of VPC."
}

variable "public_subnet_cidr" {
  type        = string
  default     = "192.168.0.0/24"
  description = "Range of internal addresses."
}

variable "private_subnet_cidr" {
  type        = string
  default     = "192.168.1.0/24"
  description = "Range of internal addresses."
}

variable "bastion_machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create bastion instance."
}

variable "bastion_boot_disk_size" {
  type        = number
  default     = 100
  description = "Bastion boot disk size in gigabytes."
}

variable "bastion_boot_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "bastion_boot_image" {
  type        = string
  default     = "gce-uefi-images/ubuntu-1804-lts"
  description = "Image from which to initialize this disk."
}

variable "bastion_network_tier" {
  type        = string
  default     = "STANDARD"
  description = "The networking tier to be used for bastion instance (valid: PREMIUM or STANDARD)"
}

variable "total_compute_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for compute instances."
}

variable "compute_machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create Spectrum Scale compute instances."
}

variable "compute_boot_image" {
  type        = string
  default     = "gce-uefi-images/ubuntu-1804-lts"
  description = "Image from which to initialize Spectrum Scale compute instances."
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

variable "compute_network_tier" {
  type        = string
  default     = "STANDARD"
  description = "The networking tier to be used for Spectrum Scale compute instances (valid: PREMIUM or STANDARD)"
}

variable "total_storage_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for compute instances."
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
  default     = "gce-uefi-images/ubuntu-1804-lts"
  description = "Image from which to initialize Spectrum Scale storage instances."
}

variable "storage_network_tier" {
  type        = string
  default     = "STANDARD"
  description = "The networking tier to be used for Spectrum Scale storage instances (valid: PREMIUM or STANDARD)"
}

variable "instances_ssh_user_name" {
  type        = string
  default     = "gcpadmin"
  description = "Name of the administrator to access the instances."
}

variable "instances_ssh_public_key_path" {
  type        = string
  description = "SSH public key local path."
}

variable "instances_ssh_private_key_path" {
  type        = string
  description = "SSH private key local path, will be used to login instances."
}

variable "data_disks_per_instance" {
  type        = number
  default     = 1
  description = "Number of data disks to be attached to each storage instance."
}

variable "data_disk_physical_block_size_bytes" {
  type        = number
  default     = 4096
  description = "Physical block size of the persistent disk, in bytes (valid: 4096, 16384)."
}

variable "data_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
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

variable "create_scale_cluster" {
  type        = bool
  default     = false
  description = "Flag to represent whether to create scale cluster or not."
}

variable "filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "Filesystem block size."
}

variable "scale_infra_repo_clone_path" {
  type        = string
  default     = "/opt/IBM/ibm-spectrumscale-cloud-deploy"
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "bucket_name" {
  type        = string
  description = "GCS bucket name to be used for backing up ansible inventory file."
}

variable "generate_ansible_inv" {
  type        = bool
  default     = true
  description = "Flag to represent whether to generate ansible inventory JSON or not."
}

variable "generate_jumphost_ssh_config" {
  type        = bool
  default     = false
  description = "Flag to represent whether to generate jump host SSH config or not."
}

variable "scale_version" {
  type        = string
  default     = "5.0.5.0"
  description = "IBM Spectrum Scale version."
}
