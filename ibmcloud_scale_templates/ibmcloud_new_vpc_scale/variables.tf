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

variable "client_ip_ranges" {
  type        = list(string)
  default     = null
  description = "List of client IP/CIDR ranges for direct connection access via VPN or direct connection."
}

variable "client_security_group_id" {
  type        = string
  default     = null
  description = "Client security group ID for cloud connection access from another VPC."
}

variable "using_cloud_connection" {
  type        = bool
  default     = false
  description = "Enable communication from a cloud VM to the VPC. Supports: (1) Same VPC with different security group, (2) Different VPC via VPC peering. Requires client_security_group_id."
}

variable "using_direct_connection" {
  type        = bool
  default     = false
  description = "Enable communication from on-premise VM to VPC via VPN or Direct Connect. Requires client_ip_ranges."
}

variable "using_jumphost_connection" {
  type        = bool
  default     = null
  description = "Enable communication from on-premise VM to VPC via bastion/jumphost. When enable_bastion=true, this is automatically enabled unless explicitly set to false. Requires bastion_security_group_id (either from module.bastion or external)."
}

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
  default     = []
  description = "List of CIDR blocks for compute cluster private subnets. Set to empty array [] to use storage cluster subnets or skip compute subnet creation."
}

variable "vpc_protocol_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks for protocol node private subnets, one per availability zone. Required only if deploying protocol nodes. Set to empty array [] to skip protocol subnet creation."
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
  default     = null
  description = "DNS domain name for storage cluster nodes. Required when deploying storage nodes."
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = null
  description = "DNS domain name for compute cluster nodes. Required only if deploying compute nodes."
}

variable "vpc_protocol_cluster_dns_domain" {
  type        = string
  default     = null
  description = "DNS domain name for protocol cluster nodes. Required only if deploying protocol nodes."
}

variable "create_dns_zone" {
  type        = bool
  default     = true
  description = "Flag to create new private DNS zones. Set to false to reuse existing DNS zones."
}

variable "enable_bastion" {
  type        = bool
  default     = true
  description = "Flag to enable or disable bastion host deployment. Set to false to skip bastion creation."
}

variable "bastion_public_key" {
  type        = string
  default     = null
  description = "SSH public key content for the bastion host. Required when enable_bastion is true."
}

variable "bastion_osimage_id" {
  type        = string
  default     = null
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

variable "total_storage_cluster_instances" {
  type        = number
  default     = 0
  description = "Total number of virtual server instances to deploy for the storage cluster. Set to 0 to skip storage cluster deployment."
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

variable "storage_cluster_public_key" {
  type        = string
  default     = null
  description = "SSH public key content for the storage cluster. Required when total_storage_cluster_instances > 0."
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

variable "storage_cluster_tiebreaker_instance_type" {
  type        = string
  default     = null
  description = "IBM Cloud VSI profile (instance type) for tie-breaker instance in Multi-AZ deployments. Set to null for single-zone deployments or to use the same profile as storage nodes."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 0
  description = "Total number of virtual server instances to deploy for the compute cluster. Set to 0 for storage-only deployments."
}

variable "compute_cluster_public_key" {
  type        = string
  default     = null
  description = "SSH public key content for the compute cluster. Required when total_compute_cluster_instances > 0."
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

variable "ces_ip_addresses" {
  type        = list(string)
  default     = []
  description = "List of CES (Cluster Export Services) IP addresses for protocol nodes. Length must equal total_protocol_instances."
}

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

variable "enable_placement_group" {
  type        = bool
  default     = true
  description = "Enable IBM Cloud placement group to distribute instances in single-AZ deployments."
}

variable "placement_group_strategy" {
  type        = string
  default     = "host_spread"
  description = "Placement group strategy. Options: 'host_spread' (place on different compute hosts), 'power_spread' (place on compute hosts that use different power sources). Note: Strategy is required and forces new resource if changed."

  validation {
    condition     = contains(["host_spread", "power_spread"], var.placement_group_strategy)
    error_message = "placement_group_strategy must be either 'host_spread' or 'power_spread'."
  }
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

variable "enable_transit_gateway" {
  type        = bool
  default     = false
  description = "Flag to enable Transit Gateway connection between the newly created VPC and an existing user-provided VPC. Transit Gateway enables connectivity across VPCs in the same or different regions."
}

variable "peer_vpc_crn" {
  type        = string
  default     = null
  description = "CRN of the existing VPC to connect via Transit Gateway. Required only if enable_transit_gateway is true and creating a new Transit Gateway."
}

variable "peer_security_group_id" {
  type        = string
  default     = null
  description = "ID of the security group in the peer VPC to attach connectivity rules to."
}

variable "transit_gateway_name" {
  type        = string
  default     = null
  description = "Name of an existing Transit Gateway to use. If not provided, a new Transit Gateway will be created and Defaults to '<resource_prefix>-tgw' if not provided."
}

variable "transit_gateway_global_routing" {
  type        = bool
  default     = false
  description = "Enable global routing for Transit Gateway to allow connections across different regions. Set to true if peer VPC is in a different region."
}

variable "root_device_kms_key_id" {
  type        = string
  default     = null
  description = "GUID of the IBM Key Protect or Hyper Protect Crypto Services (HPCS) instance for encrypting root volumes. If not provided, root volumes will not be encrypted."
}

variable "root_device_kms_key_name" {
  type        = string
  default     = null
  description = "Name of the root key or standard key in Key Protect/HPCS to use for root volume encryption. Required only if root_device_kms_key_id is provided."
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "List of tags to be attached to all resources created by this module."
}

variable "orchestrator_server" {
  type        = string
  description = "IP or hostname of the scale-orchestrator server, e.g. 10.x.x.x."
}

variable "orchestrator_port" {
  type        = number
  default     = 57096
  description = "TCP port the scale-agent connects to on the orchestrator server."
}

variable "orchestrator_ca_fingerprint" {
  type        = string
  sensitive   = true
  description = "SHA-256 fingerprint of the orchestrator's CA certificate, used to authenticate the agent-to-orchestrator TLS connection. Expected format: 'SHA256 Fingerprint=XX:XX:...:XX'."
}

