variable "enable_transit_gateway" {
  type        = bool
  nullable    = false
  description = "Flag to enable Transit Gateway for VPC connectivity. Set to true to create or use Transit Gateway."
}

variable "ibmcloud_api_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "IBM Cloud API key for authentication and resource provisioning."
}

variable "peer_vpc_crn" {
  type        = string
  default     = null
  description = "CRN of the peer VPC to connect via Transit Gateway. Required if enable_transit_gateway is true."
}

variable "resource_group_id" {
  type        = string
  nullable    = false
  description = "ID of the IBM Cloud resource group where Transit Gateway resources will be created."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix added to all resource names for identification and organization."
}

variable "transit_gateway_global_routing" {
  type        = bool
  default     = false
  description = "Enable global routing for Transit Gateway to allow connections across different regions."
}

variable "transit_gateway_name" {
  type        = string
  default     = null
  description = "Name of an existing Transit Gateway to use. If not provided, a new Transit Gateway will be created and Defaults to '<resource_prefix>-tgw' if not provided."
}

variable "vpc_crn" {
  type        = string
  nullable    = false
  description = "CRN of the newly created VPC to attach to Transit Gateway."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "IBM Cloud region where the Transit Gateway will be created."
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Tags to be applied to Transit Gateway resources."
}

variable "vpc_cidr_block" {
  type        = string
  default     = null
  description = "CIDR block of the new VPC. Used as source IP range for security rules in peer VPC."
}
