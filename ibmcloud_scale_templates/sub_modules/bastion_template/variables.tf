variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "A list of availability zones names or ids in the region."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud resource group id."
}

variable "vpc_id" {
  type        = string
  description = "VPC id were to deploy the bastion."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDRs that can access to the bastion. Default : 0.0.0.0/0"
}

variable "bastion_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-20-04-2-minimal-amd64-1"
  description = "Bastion OS image name."
}

variable "bastion_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for Bastion virtual server instance."
}

variable "bastion_key_pair" {
  type        = string
  description = "The key pair to use to launch the bastion host."
}

variable "bastion_subnet_id" {
  type        = string
  description = "Subnet id to be used for Bastion virtual server instance."
}
