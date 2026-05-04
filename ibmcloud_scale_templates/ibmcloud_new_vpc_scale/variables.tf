# ========================================
# IBM Cloud Authentication Settings
# ========================================

variable "ibmcloud_api_key" {
  type        = string
  sensitive   = true
  description = "IBM Cloud API key for authentication."
}

variable "resource_group" {
  type        = string
  default     = null
  description = "Name of an existing IBM Cloud resource group. If not provided, a new resource group will be created using the resource_prefix."
}

variable "resource_prefix" {
  type        = string
  default     = "ibm-storage-scale"
  description = "Prefix added to all resource names for identification and organization."
}

variable "boot_disk_type" {
  type        = string
  default     = null
  description = "Boot disk profile/type for all cluster instances (e.g., general-purpose, 5iops-tier, 10iops-tier)."
}

# ========================================
# VPC Network Configuration
# ========================================

variable "vpc_region" {
  type        = string
  description = "IBM Cloud region where VPC and all resources will be deployed (e.g., us-east, us-south, eu-de)."
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "List of availability zone names or IDs within the selected region for multi-zone deployment."
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.241.0.0/18"
  description = "CIDR block for VPC that will be automatically subdivided into address prefixes for each availability zone."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.1.0/24", "10.241.64.1/24", "10.241.128.1/24"]
  description = "List of CIDR blocks for storage cluster private subnets, one per availability zone."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.0.0/24"]
  description = "List of CIDR blocks for compute cluster private subnets. Set to empty array [] to use storage cluster subnets instead."
}

variable "vpc_protocol_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.2.0/24", "10.241.65.0/24", "10.241.129.0/24"]
  description = "List of CIDR blocks for protocol node private subnets, one per availability zone. Required only if deploying protocol nodes."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.241.3.0/24", "10.241.66.0/24", "10.241.130.0/24"]
  description = "List of CIDR blocks for public subnets, one per availability zone. Set to empty array [] if no public subnets are needed."
}

variable "dns_service_instance_id" {
  type        = string
  default     = null
  description = "GUID of the IBM Cloud DNS Services instance for DNS record management. If not provided, a new DNS service instance will be created."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  default     = "strgscale.com"
  description = "DNS domain name for storage cluster nodes."
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = "compscale.com"
  description = "DNS domain name for compute cluster nodes."
}

variable "vpc_protocol_cluster_dns_domain" {
  type        = string
  default     = "protoscale.com"
  description = "DNS domain name for protocol cluster nodes."
}

variable "vpc_reverse_dns_domain" {
  type        = string
  default     = "10.in-addr.arpa"
  description = "Reverse DNS domain name for reverse DNS lookups (PTR records)."
}

variable "create_dns_zone" {
  type        = bool
  default     = true
  description = "Flag to create new private DNS zones. Set to false to reuse existing DNS zones."
}

# ========================================
# Bastion Host Configuration
# ========================================

variable "enable_bastion" {
  type        = bool
  default     = true
  description = "Flag to enable or disable bastion host deployment. Set to false to skip bastion creation."
}

variable "bastion_public_key_path" {
  type        = string
  default     = null
  description = "Path to the SSH public key file for bastion host access. Required only if enable_bastion is true."

  validation {
    condition     = var.bastion_public_key_path == null || fileexists(var.bastion_public_key_path)
    error_message = "The bastion_public_key_path must be a valid file path to an existing SSH public key file: ${var.bastion_public_key_path}"
  }
}

variable "bastion_osimage_id" {
  type        = string
  description = "IBM Cloud OS image ID for bastion virtual server instance. Use 'ibmcloud is images' to find available image IDs in your region."
}

variable "bastion_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "IBM Cloud VSI profile (instance type) for bastion host."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access the bastion host via SSH."
}

# ========================================
# Storage Cluster Configuration
# ========================================

variable "total_storage_cluster_instances" {
  type        = number
  default     = 4
  description = "Total number of virtual server instances to deploy for the storage cluster."
}

variable "total_storage_volumes" {
  type        = number
  default     = 0
  description = "Total number of unattached storage volumes to provision. These volumes will be created but not attached to any instances."
}

variable "storage_volume_size" {
  type        = number
  default     = 100
  description = "Size of each unattached storage volume in GB."
}

variable "storage_volume_profile" {
  type        = string
  default     = "general-purpose"
  description = "IBM Cloud volume profile for unattached storage volumes (e.g., general-purpose, 5iops-tier, 10iops-tier, custom)."
}

variable "storage_volume_iops" {
  type        = number
  default     = null
  description = "IOPS for unattached storage volumes. Only applicable for custom IOPS profiles."
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

variable "storage_vsi_osimage_id" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "IBM Cloud OS image ID for storage cluster virtual server instances. Format: r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx. Use 'ibmcloud is images' to find available image IDs in your region."
}

variable "storage_vsi_profile" {
  type        = string
  default     = "bx2d-8x32"
  description = "IBM Cloud VSI profile (instance type) for storage cluster nodes."
}

# ========================================
# Compute Cluster Configuration
# ========================================

variable "total_compute_cluster_instances" {
  type        = number
  default     = 3
  description = "Total number of virtual server instances to deploy for the compute cluster."
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

variable "compute_vsi_osimage_id" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "IBM Cloud OS image ID for compute cluster virtual server instances. Format: r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx. Use 'ibmcloud is images' to find available image IDs in your region."
}

variable "compute_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "IBM Cloud VSI profile (instance type) for compute cluster nodes."
}

# ========================================
# Protocol Cluster Configuration
# ========================================

variable "total_protocol_instances" {
  type        = number
  default     = 0
  description = "Total number of virtual server instances to deploy for protocol nodes (CES/NFS). Set to 0 to skip protocol node deployment."
}

variable "protocol_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "IBM Cloud VSI profile (instance type) for protocol cluster nodes."
}

# ========================================
# Gateway Cluster Configuration
# ========================================

variable "total_gateway_instances" {
  type        = number
  default     = 0
  description = "Total number of virtual server instances to deploy for gateway nodes. Set to 0 to skip gateway node deployment."
}

variable "gateway_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "IBM Cloud VSI profile (instance type) for gateway cluster nodes."
}

# ========================================
# Advanced Options
# ========================================

variable "enable_placement_group" {
  type        = bool
  default     = true
  description = "Enable IBM Cloud placement group with host_spread strategy to distribute instances across different physical hosts in single-AZ deployments."
}

variable "cluster_type" {
  type        = string
  default     = "Combined-compute-storage"
  description = "Cluster type to provision. Options: 'Storage-only', 'Compute-only', 'Combined-compute-storage'."

  validation {
    condition     = contains(["Storage-only", "Compute-only", "Combined-compute-storage"], var.cluster_type)
    error_message = "cluster_type must be one of: 'Storage-only', 'Compute-only', 'Combined-compute-storage'."
  }
}

# ========================================
# Transit Gateway Configuration
# ========================================

variable "enable_transit_gateway" {
  type        = bool
  default     = false
  description = "Flag to enable Transit Gateway connection between the newly created VPC and an existing user-provided VPC. Transit Gateway enables connectivity across VPCs in the same or different regions."
}

variable "transit_gateway_id" {
  type        = string
  default     = null
  description = "ID of an existing Transit Gateway to attach the new VPC to. If not provided and enable_transit_gateway is true, a new Transit Gateway will be created."
}

variable "peer_vpc_crn" {
  type        = string
  default     = null
  description = "CRN of the existing VPC to connect via Transit Gateway. Required only if enable_transit_gateway is true and creating a new Transit Gateway."
}

variable "transit_gateway_name" {
  type        = string
  default     = null
  description = "Name for the new Transit Gateway. Used only if enable_transit_gateway is true and transit_gateway_id is not provided. Defaults to '<resource_prefix>-tgw'."
}

variable "transit_gateway_global_routing" {
  type        = bool
  default     = false
  description = "Enable global routing for Transit Gateway to allow connections across different regions. Set to true if peer VPC is in a different region."
}

# ========================================
# Tagging Configuration
# ========================================

variable "tags" {
  type        = list(string)
  default     = []
  description = "List of tags to be attached to all resources created by this module."
}
