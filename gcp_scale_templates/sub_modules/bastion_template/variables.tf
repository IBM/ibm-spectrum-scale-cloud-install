variable "bastion_boot_disk_size" {
  type        = number
  nullable    = false
  description = "Bastion instance boot disk size in gigabytes."
}

variable "bastion_boot_disk_type" {
  type        = string
  nullable    = false
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "bastion_image_ref" {
  type        = string
  nullable    = false
  description = "Image from which to initialize bastion instance."
}

variable "bastion_instance_type" {
  type        = string
  nullable    = false
  description = "GCP instance machine type to create bastion instance."
}

variable "bastion_network_tier" {
  type        = string
  nullable    = false
  description = "The networking tier to be used for bastion instance (valid: PREMIUM or STANDARD)"
}

variable "bastion_public_ssh_port" {
  type        = number
  nullable    = false
  description = "Set the SSH port to use from desktop to the bastion."
}

variable "bastion_ssh_key_path" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "SSH public key local path, will be used to login bastion instance."
}

variable "bastion_ssh_user_name" {
  type        = string
  nullable    = false
  description = "Name of the administrator to access the bastion instance."
}

variable "credential_json_path" {
  type        = string
  nullable    = false
  description = "The path of a GCP service account key file in JSON format."
}

variable "desired_instance_count" {
  type        = number
  nullable    = false
  description = "Bastion instance desired count."
}

variable "project_id" {
  type        = string
  nullable    = false
  description = "GCP project ID to manage resources."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  nullable    = false
  description = "Firewall will allow only to traffic that has source IP address in these ranges."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created."
}

variable "vpc_auto_scaling_group_subnets" {
  type        = list(string)
  nullable    = false
  description = "Public subnet name to attach the bastion interface."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = false
  description = "Zone in which bastion machine should be created."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "GCP VPC name"
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "GCP region where the resources will be created."
}
