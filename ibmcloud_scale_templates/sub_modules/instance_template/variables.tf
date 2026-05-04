# ========================================
# Authentication
# ========================================

variable "ibmcloud_api_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The IBM Cloud platform API key."
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud resource group ID."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created."
}
variable "tags" {
  type        = list(string)
  default     = []
  description = "List of tags to attach to resources in format key:value"
}

# ========================================
# VPC Network
# ========================================

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "VPC id were to deploy the bastion."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "IBM Cloud region where resources will be provisioned. Example: us-south."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = false
  description = "A list of availability zones names or ids in the region."
}

variable "dns_service_instance_id" {
  type        = string
  nullable    = true
  default     = null
  description = "IBM Cloud DNS Service Instance Id"
}

variable "vpc_storage_cluster_dns_zone_id" {
  type        = string
  nullable    = true
  default     = null
  description = "DNS zone ID for storage cluster."
}

variable "vpc_compute_cluster_dns_zone_id" {
  type        = string
  nullable    = true
  default     = null
  description = "DNS zone ID for compute cluster."
}

variable "vpc_reverse_dns_zone_id" {
  type        = string
  nullable    = true
  default     = null
  description = "DNS zone ID for reverse DNS lookups."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  description = "List of IDs of storage cluster private subnets."
}

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  description = "List of IDs of compute cluster private subnets."
}

variable "vpc_protocol_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  description = "List of IDs of protocol cluster private subnets."
}

# ========================================
# Bastion
# ========================================

variable "bastion_security_group_id" {
  type        = string
  nullable    = true
  description = "Bastion security group ID."
}

variable "using_jumphost_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_security_group_ref`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

# ========================================
# Storage Cluster
# ========================================

variable "boot_disk_type" {
  type        = string
  nullable    = true
  description = "Boot disk type for all cluster instances."
}

variable "storage_cluster_image_id" {
  type        = string
  nullable    = true
  description = "Image ID to use for provisioning the storage cluster instances."
}

variable "storage_cluster_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the storage cluster instances."
}

variable "storage_cluster_public_key_path" {
  type        = string
  nullable    = false
  description = "The ssh public key to be created used to launch the storage cluster."

  validation {
    condition     = fileexists(var.storage_cluster_public_key_path)
    error_message = "The storage_cluster_public_key_path must be a valid file path to an existing SSH public key file: ${var.storage_cluster_public_key_path}"
  }
}

variable "storage_cluster_tiebreaker_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration)."
}

variable "total_storage_cluster_instances" {
  type        = number
  nullable    = true
  description = "Number of virtual server instances to be launched for storage cluster."
}

variable "total_storage_volumes" {
  type        = number
  nullable    = true
  description = "Number of unattached storage volumes to provision."
}

variable "storage_volume_size" {
  type        = number
  nullable    = true
  description = "Size of each unattached storage volume in GB."
}

variable "storage_volume_profile" {
  type        = string
  nullable    = true
  description = "IBM Cloud volume profile for unattached storage volumes."
}

variable "storage_volume_iops" {
  type        = number
  nullable    = true
  description = "IOPS for unattached storage volumes."
}

# ========================================
# Compute Cluster
# ========================================

variable "compute_cluster_image_id" {
  type        = string
  nullable    = true
  description = "Image ID to use for provisioning the compute cluster instances."
}

variable "compute_cluster_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "compute_cluster_public_key_path" {
  type        = string
  nullable    = false
  description = "The ssh public key to be created used to launch the compute cluster."

  validation {
    condition     = fileexists(var.compute_cluster_public_key_path)
    error_message = "The compute_cluster_public_key_path must be a valid file path to an existing SSH public key file: ${var.compute_cluster_public_key_path}"
  }
}

variable "total_compute_cluster_instances" {
  type        = number
  nullable    = true
  description = "Number of virtual server instances to be launched for compute cluster."
}

# ========================================
# Protocol Cluster
# ========================================

variable "ces_ip_addresses" {
  type        = list(string)
  nullable    = true
  description = "CES IP addresses (length must be equal to number of protocol nodes)."
}

variable "protocol_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the protocol instances."
}

variable "total_protocol_instances" {
  type        = number
  nullable    = true
  description = "Number of virtual server instances to be launched for protocol nodes."
}

# ========================================
# Gateway Cluster
# ========================================

variable "gateway_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the gateway instances."
}

variable "total_gateway_instances" {
  type        = number
  nullable    = true
  description = "Number of virtual server instances to be launched for gateway nodes."
}

# ========================================
# Advanced Options
# ========================================

variable "airgap" {
  type        = bool
  nullable    = true
  description = "If true, instance iam profile, git utils which need internet access will be skipped."
}

variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
}

variable "root_device_kms_key_id" {
  type        = string
  nullable    = true
  description = "GUID of the Key Protect/HPCS instance to be used when encrypting the root volume."
}

variable "root_device_kms_key_name" {
  type        = string
  nullable    = true
  description = "Name of the root/standard key to be used when encrypting the root volume."
}

variable "enable_placement_group" {
  type        = bool
  nullable    = true
  description = "If true, an IBM Cloud placement group will be created for single-AZ deployments and attached to storage instances."
}

variable "placement_group_strategy" {
  type        = string
  nullable    = true
  description = "Placement group strategy. Options: 'host_spread' (place on different compute hosts), 'power_spread' (place on compute hosts that use different power sources)."
}
