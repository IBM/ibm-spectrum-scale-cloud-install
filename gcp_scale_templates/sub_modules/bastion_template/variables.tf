variable "vpc_region" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP region where the resources will be created."
}

variable "vpc_name" {
  type        = string
  default     = "spectrum-scale-vpc"
  description = "GCP VPC name"
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "project_id" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP project ID to manage resources."
}

variable "credential_json_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "vpc_auto_scaling_group_subnets" {
  type        = list(string)
  default     = ["spectrum-scale-public-subnet-0"]
  description = "Public subnet name to attach the bastion interface."
}

variable "vpc_zone" {
  type        = string
  description = "Zone in which bastion machine should be created."
}

variable "bastion_instance_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create bastion instance."
}

variable "desired_instance_count" {
  type        = number
  default     = 1
  description = "Bastion instance desired count."
}

variable "bastion_boot_disk_size" {
  type        = number
  default     = 100
  description = "Bastion instance boot disk size in gigabytes."
}

variable "bastion_boot_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "bastion_image_ref" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
  description = "Image from which to initialize bastion instance."
}

variable "bastion_network_tier" {
  type        = string
  default     = "STANDARD"
  description = "The networking tier to be used for bastion instance (valid: PREMIUM or STANDARD)"
}

variable "bastion_ssh_user_name" {
  type        = string
  default     = "gcpadmin"
  description = "Name of the administrator to access the bastion instance."
}

variable "bastion_ssh_key_path" {
  type        = string
  description = "SSH public key local path, will be used to login bastion instance."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Firewall will allow only to traffic that has source IP address in these ranges."
}
