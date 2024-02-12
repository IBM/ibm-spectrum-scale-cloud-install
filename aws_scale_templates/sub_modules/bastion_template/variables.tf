variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id were to deploy the bastion."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created."
}

variable "bastion_public_ssh_port" {
  type        = number
  nullable    = false
  description = "Set the SSH port to use from desktop to the bastion."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  nullable    = false
  description = "List of CIDRs that can access to the bastion. Example: 0.0.0.0/0"
}

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

variable "vpc_auto_scaling_group_subnets" {
  type        = list(string)
  nullable    = false
  description = "List of subnet were the Auto Scalling Group will deploy the instances."
}
