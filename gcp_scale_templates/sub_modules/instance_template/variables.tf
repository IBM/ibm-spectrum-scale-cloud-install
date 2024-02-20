variable "airgap" {
  type        = bool
  nullable    = true
  description = "If true, instance iam profile, git utils which need internet access will be skipped."
}

variable "bastion_instance_public_ip" {
  type        = string
  nullable    = true
  description = "Bastion instance public ip address."
}

variable "bastion_instance_ref" {
  type        = string
  nullable    = true
  description = "Bastion instance reference."
}

variable "bastion_security_group_ref" {
  type        = string
  nullable    = true
  description = "Bastion security group reference (id/self-link)."
}

variable "bastion_ssh_private_key" {
  type        = string
  nullable    = true
  description = "Bastion SSH private key path, which will be used to login to bastion host."
}

variable "bastion_user" {
  type        = string
  nullable    = true
  description = "Bastion login username."
}

variable "client_security_group_ref" {
  type        = string
  nullable    = true
  description = "Client security group reference (id/self-link)."
}

variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
}

variable "compute_cluster_boot_disk_size" {
  type        = string
  nullable    = true
  description = "Compute instances boot disk size in gigabytes."
}

variable "compute_cluster_boot_disk_type" {
  type        = string
  nullable    = true
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  nullable    = true
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "compute_cluster_gui_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "Password for Compute cluster GUI."
}

variable "compute_cluster_gui_username" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_image_ref" {
  type        = string
  nullable    = true
  description = "Image from which to initialize Spectrum Scale compute instances."
}

variable "compute_cluster_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "compute_cluster_public_key_path" {
  type        = string
  nullable    = true
  description = "SSH public key local path for compute instances."
}

variable "create_clouddns" {
  type        = bool
  nullable    = true
  description = "Indicates whether to create new cloud DNS zones or reuse existing DNS zones."
}

variable "create_remote_mount_cluster" {
  type        = bool
  nullable    = true
  description = "Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup."
}

variable "create_scale_cluster" {
  type        = bool
  nullable    = true
  description = "Flag to represent whether to create scale cluster or not."
}

variable "credential_json_path" {
  type        = string
  nullable    = false
  description = "The path of a GCP service account key file in JSON format."
}

variable "filesystem_parameters" {
  type = list(object({
    name                         = string
    filesystem_config_file       = string
    filesystem_kms_key_ring_ref  = string
    filesystem_kms_key_ref       = string
    device_delete_on_termination = bool
    disk_config = list(object({
      filesystem_pool                    = string
      block_devices_per_storage_instance = number
      block_device_volume_type           = string
      block_device_volume_size           = string
    }))
  }))
  nullable    = true
  description = "Filesystem parameters in relationship with disk parameters."
}

variable "gateway_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the gateway instances."
}

variable "instances_ssh_user_name" {
  type        = string
  nullable    = false
  description = "Compute/Storage VM login username."
}

variable "inventory_format" {
  type        = string
  nullable    = true
  description = "Specify inventory format suited for ansible playbooks."
}

variable "physical_block_size_bytes" {
  type        = number
  nullable    = true
  description = "Physical block size of the persistent disk, in bytes (valid: 4096, 16384)."
}

variable "project_id" {
  type        = string
  nullable    = false
  description = "GCP project ID to manage resources."
}

variable "protocol_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the protocol instances."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "GCP stack name, will be used for tagging resources."
}

variable "root_device_kms_key_ref" {
  type        = string
  nullable    = true
  description = "GCP KMS Key reference to use when encrypting the volume."
}

variable "root_device_kms_key_ring_ref" {
  type        = string
  nullable    = true
  description = "GCP KMS Key ring reference to use when encrypting the volume."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  nullable    = true
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "scopes" {
  type        = list(string)
  nullable    = true
  description = "List of service scopes."
}

variable "scratch_devices_per_storage_instance" {
  type        = number
  nullable    = true
  description = "Number of scratch disks to be attached to each storage instance."
}

variable "service_email" {
  type        = string
  nullable    = true
  description = "GCP service account e-mail address."
}

variable "spectrumscale_rpms_path" {
  type        = string
  nullable    = true
  description = "Path that contains IBM Spectrum Scale product cloud rpms."
}

variable "storage_cluster_boot_disk_size" {
  type        = number
  nullable    = true
  description = "Storage instances boot disk size in gigabytes."
}

variable "storage_cluster_boot_disk_type" {
  type        = string
  nullable    = true
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "storage_cluster_gui_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "Password for Storage cluster GUI"
}

variable "storage_cluster_gui_username" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_image_ref" {
  type        = string
  nullable    = true
  description = "Image from which to initialize Spectrum Scale storage instances."
}

variable "storage_cluster_instance_type" {
  type        = string
  nullable    = true
  description = "GCP instance machine type to create Spectrum Scale storage instances."
}

variable "storage_cluster_public_key_path" {
  type        = string
  nullable    = true
  description = "SSH public key local path for storage instances."
}

variable "total_compute_cluster_instances" {
  type        = number
  nullable    = true
  description = "Number of GCP instances to be launched for compute cluster."
}

variable "total_gateway_instances" {
  type        = number
  nullable    = true
  description = "Number of EC2 instances to be launched for gateway nodes."
}

variable "total_protocol_instances" {
  type        = number
  nullable    = true
  description = "Number of EC2 instances to be launched for protocol nodes."
}

variable "total_storage_cluster_instances" {
  type        = number
  nullable    = true
  description = "Number of instances to be launched for storage instances."
}

variable "use_clouddns" {
  type        = bool
  nullable    = true
  description = "Indicates whether to use cloud DNS or internal DNS."
}

variable "using_cloud_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between a cloud virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `client_security_group_ref` (make sure it is in the same vpc), as the cloud VM security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_direct_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud virtual private cloud (VPC) via a VPN or direct connection. This mode requires variable `client_ip_ranges`, as the on-premise client ip will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_jumphost_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_packer_image" {
  type        = bool
  nullable    = true
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "using_rest_api_remote_mount" {
  type        = string
  nullable    = true
  description = "If false, skips GUI initialization on compute cluster for remote mount configuration."
}












variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = false
  description = "A list of availability zones names or ids in the region."
}
































# Note:
# 1. A private DNS Zone name will be created "resource_prefix" to store A/forward records
# 2. A seperae private DNS zone name will be created with "resource_prefix-reverse" to store PTR records
variable "vpc_compute_cluster_dns_domain" { # equivalent to DNS name
  type        = string
  nullable    = true
  description = "GCP Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  description = "List of IDs of compute cluster private subnets."
}

variable "vpc_compute_cluster_private_subnets_cidr_block" {
  type        = string
  nullable    = true
  description = "cidr_block of compute private subnet."
}

variable "vpc_forward_dns_zone" {
  type        = string
  nullable    = true
  description = "GCP Cloud DNS zone name to be used for scale cluster (Ex: example-zone)."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id were to deploy the bastion."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "GCP region where the resources will be created."
}

variable "vpc_reverse_dns_zone" {
  type        = string
  nullable    = true
  description = "GCP Cloud DNS reverse zone lookup to be used for scale cluster (Ex: example-zone-reverse)."
}

variable "vpc_storage_cluster_dns_domain" { # equivalent to DNS name
  type        = string
  nullable    = true
  description = "GCP Cloud DNS domain name to be used for storage cluster."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  description = "List of IDs of storage cluster private subnets."
}

variable "vpc_storage_cluster_private_subnets_cidr_block" {
  type        = string
  nullable    = true
  description = "cidr_block of storage private subnet."
}
