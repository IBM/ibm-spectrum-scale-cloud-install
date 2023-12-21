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

variable "compute_cluster_image_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "Image from which to initialize Spectrum Scale compute instances."
}

variable "using_rest_api_remote_mount" {
  type        = string
  nullable    = true
  default     = null
  description = "If false, skips GUI initialization on compute cluster for remote mount configuration."
}

variable "compute_cluster_gui_username" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_gui_password" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "Password for Compute cluster GUI."
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

variable "block_device_kms_key_ring_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP KMS Key ring reference to use when encrypting the volume."
}

variable "block_device_kms_key_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP KMS Key reference to use when encrypting the volume."
}

variable "scratch_devices_per_storage_instance" {
  type        = number
  nullable    = true
  default     = 0
  description = "Number of scratch disks to be attached to each storage instance."
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

variable "physical_block_size_bytes" {
  type        = number
  default     = 4096
  description = "Physical block size of the persistent disk, in bytes (valid: 4096, 16384)."
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

variable "bastion_instance_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion instance reference."
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
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud virtual private cloud (VPC) via a VPN or direct connection. This mode requires variable `client_ip_ranges`, as the on-premise client ip will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_cloud_connection" {
  type        = bool
  nullable    = true
  default     = null
  description = "This flag is intended to enable ansible related communication between a cloud virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `client_security_group_ref` (make sure it is in the same vpc), as the cloud VM security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_jumphost_connection" {
  type        = bool
  nullable    = true
  default     = null
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
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

variable "bastion_security_group_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion security group reference (id/self-link)."
}

variable "client_security_group_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "Client security group reference (id/self-link)."
}

variable "use_clouddns" {
  type        = bool
  nullable    = true
  default     = null
  description = "Indicates whether to use cloud DNS or internal DNS."
}

variable "create_clouddns" {
  type        = bool
  nullable    = true
  default     = null
  description = "Indicates whether to create new cloud DNS zones or reuse existing DNS zones."
}

variable "vpc_compute_cluster_private_subnets_cidr_block" {
  type        = string
  nullable    = true
  default     = null
  description = "cidr_block of compute private subnet."
}

variable "vpc_storage_cluster_private_subnets_cidr_block" {
  type        = string
  nullable    = true
  default     = null
  description = "cidr_block of storage private subnet."
}

variable "vpc_forward_dns_zone" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP Cloud DNS zone name to be used for scale cluster (Ex: example-zone)."
}

variable "vpc_reverse_dns_zone" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP Cloud DNS reverse zone lookup to be used for scale cluster (Ex: example-zone-reverse)."
}

# Note:
# 1. A private DNS Zone name will be created "resource_prefix" to store A/forward records
# 2. A seperae private DNS zone name will be created with "resource_prefix-reverse" to store PTR records
variable "vpc_compute_cluster_dns_domain" { # equivalent to DNS name
  type        = string
  default     = "compscale.com"
  description = "GCP Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_storage_cluster_dns_domain" { # equivalent to DNS name
  type        = string
  default     = "strgscale.com"
  description = "GCP Cloud DNS domain name to be used for storage cluster."
}

variable "gateway_instance_type" {
  type        = string
  nullable    = true
  default     = null
  description = "Instance type to use for provisioning the gateway instances."
}

variable "total_gateway_instances" {
  type        = number
  nullable    = true
  default     = null
  description = "Number of EC2 instances to be launched for gateway nodes."
}

variable "protocol_instance_type" {
  type        = string
  nullable    = true
  default     = null
  description = "Instance type to use for provisioning the protocol instances."
}

variable "total_protocol_instances" {
  type        = number
  nullable    = true
  default     = null
  description = "Number of EC2 instances to be launched for protocol nodes."
}
