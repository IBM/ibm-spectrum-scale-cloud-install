variable "generate_jumphost_ssh_config" {
  type        = bool
  default     = false
  description = "Flag to represent whether to generate jump host SSH config or not."
}

variable "region" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "GCP region where the resources will be created."
}

variable "zones" {
  type        = list(string)
  description = "GCP zones that the instances should be created."
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID to manage resources."
}

variable "credentials_file_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "stack_name" {
  type        = string
  default     = "spectrum-scale"
  description = "GCP stack name, will be used for tagging resources."
}

variable "vpc_name" {
  type        = string
  default     = "spectrum-scale-vpc"
  description = "GCP VPC name."
}

variable "tf_data_path" {
  type        = string
  default     = "~/tf_data_path"
  description = "Data path to be used by terraform for storing ssh keys."
}

variable "tf_input_json_root_path" {
  type        = string
  default     = null
  description = "Terraform module absolute path."
}

variable "tf_input_json_file_name" {
  type        = string
  default     = null
  description = "Terraform module input variable defintion/json file name."
}

variable "bucket_name" {
  type        = string
  description = "s3 bucket name to be used for backing up ansible inventory file."
}

variable "scale_infra_repo_clone_path" {
  type        = string
  default     = "/opt/IBM/ibm-spectrumscale-cloud-deploy"
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
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

variable "private_subnet_name" {
  type        = string
  default     = "spectrum-scale-private-subnet"
  description = "Subnetwork of a Virtual Private Cloud network with one primary IP range"
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

variable "compute_instance_name_prefix" {
  type        = string
  default     = "compute"
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
  default     = "gce-uefi-images/ubuntu-1804-lts"
  description = "Image from which to initialize Spectrum Scale compute instances."
}

variable "compute_network_tier" {
  type        = string
  default     = "STANDARD"
  description = "The networking tier to be used for Spectrum Scale compute instances (valid: PREMIUM or STANDARD)."
}

variable "compute_instance_tags" {
  type        = list(string)
  description = "List of tags to attach to the compute instance."
}

variable "total_storage_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for storage instances."
}

variable "storage_machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create Spectrum Scale storage instances."
}

variable "storage_instance_name_prefix" {
  type        = string
  default     = "storage"
  description = "Storage instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
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
  description = "The networking tier to be used for Spectrum Scale compute instances (valid: PREMIUM or STANDARD)."
}

variable "instances_ssh_user_name" {
  type        = string
  default     = "gcpadmin"
  description = "Name of the administrator to access the bastion instance."
}

variable "instances_ssh_public_key_path" {
  type        = string
  description = "SSH public key local path."
}

variable "data_disks_device_names" {
  type = list(string)
  default = ["/dev/sdb", "/dev/sdc", "/dev/sdd", "/dev/sde",
    "/dev/sdf", "/dev/sdg", "/dev/sdh", "/dev/sdi",
    "/dev/sdj", "/dev/sdk", "/dev/sdl", "/dev/sdm",
  "/dev/sdn", "/dev/sdo", "/dev/sdp"]
  description = "Name of the block device to mount on the instance."
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

variable "generate_ansible_inv" {
  type        = bool
  default     = true
  description = "Flag to represent whether to generate ansible inventory JSON or not."
}

variable "instances_ssh_private_key_path" {
  type        = string
  description = "SSH private key local path, which will be used to login to bastion host."
}

variable "bastion_public_ip" {
  type        = string
  description = "Bastion public ip."
}

variable "scale_version" {
  type        = string
  default     = "5.0.5.0"
  description = "IBM Spectrum Scale version."
}

variable "private_subnet_cidr" {
  type        = string
  default     = "192.168.1.0/24"
  description = "Range of internal addresses."
}
