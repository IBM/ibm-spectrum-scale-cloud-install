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

# ========================================
# Bastion
# ========================================

variable "bastion_security_group_id" {
  type        = string
  nullable    = true
  description = "Bastion security group ID."
}

variable "client_ip_ranges" {
  type        = list(string)
  nullable    = true
  description = "List of client IP/CIDR ranges for direct connection access."
}

variable "client_security_group_id" {
  type        = string
  nullable    = true
  description = "Client security group ID for cloud connection access (same VPC or peered VPC)."
}

variable "using_cloud_connection" {
  type        = bool
  nullable    = true
  default     = false
  description = "Enable communication from a cloud VM to the VPC. Supports: (1) Same VPC with different security group, (2) Different VPC via VPC peering. Requires `client_security_group_id` - the deployment VM's security group will be added to the allowed ingress list of scale cluster security groups."
}

variable "using_direct_connection" {
  type        = bool
  nullable    = true
  default     = false
  description = "Enable communication from on-premise VM to VPC via VPN or Direct Connect. Requires `client_ip_ranges` - the on-premise client IPs/CIDRs will be added to the allowed ingress list of scale cluster security groups."
}

variable "using_jumphost_connection" {
  type        = bool
  nullable    = true
  default     = false
  description = "Enable communication from on-premise VM to VPC via bastion/jumphost. Requires `bastion_user`, `bastion_instance_public_ip`, `bastion_security_group_id`, `bastion_ssh_private_key` - the bastion security group will be added to the allowed ingress list of scale cluster security groups."
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
  default     = null
  description = "The ssh public key to be created used to launch the storage cluster. Required only when total_storage_cluster_instances > 0."

  validation {
    condition     = var.storage_cluster_public_key_path == null || fileexists(var.storage_cluster_public_key_path)
    error_message = "The storage_cluster_public_key_path must be a valid file path to an existing SSH public key file when provided."
  }

  validation {
    condition     = var.total_storage_cluster_instances == 0 || var.storage_cluster_public_key_path != null
    error_message = "The storage_cluster_public_key_path is required when total_storage_cluster_instances > 0."
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
  default     = null
  description = "The ssh public key to be created used to launch the compute cluster. Required only when total_compute_cluster_instances > 0."

  validation {
    condition     = var.compute_cluster_public_key_path == null || fileexists(var.compute_cluster_public_key_path)
    error_message = "The compute_cluster_public_key_path must be a valid file path to an existing SSH public key file when provided."
  }

  validation {
    condition     = var.total_compute_cluster_instances == 0 || var.compute_cluster_public_key_path != null
    error_message = "The compute_cluster_public_key_path is required when total_compute_cluster_instances > 0."
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
