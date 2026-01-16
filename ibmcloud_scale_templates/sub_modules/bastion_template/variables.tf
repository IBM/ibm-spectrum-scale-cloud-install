variable "bastion_image_ref" {
  type        = string
  nullable    = false
  description = "Bastion AMI Image id."
}

variable "bastion_instance_type" {
  type        = string
  nullable    = false
  description = "Instance type to use for the bastion instance."
}

variable "bastion_key_pair" {
  type        = string
  nullable    = false
  description = "The key pair to use to launch the bastion host."
}

variable "bastion_public_ssh_port" {
  type        = number
  nullable    = false
  description = "Set the SSH port to use from desktop to the bastion."
}

variable "desired_instance_count" {
  type        = number
  nullable    = false
  description = "Bastion instance desired count."
}

variable "ibmcloud_api_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The IBM Cloud platform API key."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDRs that can access to the bastion. Default : 0.0.0.0/0"
}

variable "resource_group_name" {
  type        = string
  nullable    = true
  description = "The name of a resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created. Example: ibm-storage-scale"
}

variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "vpc_auto_scaling_group_subnets" {
  type        = list(string)
  nullable    = false
  description = "List of subnet were the Auto Scaling Group will deploy the instances."
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "A list of availability zones names or ids in the region."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id were to deploy the bastion."
}
