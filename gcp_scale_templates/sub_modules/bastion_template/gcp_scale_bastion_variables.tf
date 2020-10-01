variable "region" {
  type        = string
  description = "GCP region where the resources will be created."
}

variable "bastion_zone" {
  type        = string
  description = "Zone in which bastion machine should be created."
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID to manage resources."
}

variable "credentials_file_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "stack_name" {
  type        = string
  default     = "spectrum-scale"
  description = "GCP stack name, will be used for tagging resources."
}

variable "vpc_name" {
  type        = string
  default     = "spectrum-scale-vpc"
  description = "GCP VPC name"
}

variable "public_subnet_name" {
  type        = string
  default     = "spectrum-scale-public-subnet"
  description = "Public subnet name to attach the bastion interface."
}

variable "bastion_machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create bastion instance."
}

variable "bastion_instance_name_prefix" {
  type        = string
  default     = "bastion"
  description = "Bastion instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
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

variable "bastion_boot_image" {
  type        = string
  default     = "gce-uefi-images/ubuntu-1804-lts"
  description = "Image from which to initialize bastion instance."
}

variable "bastion_network_tier" {
  type        = string
  default     = "STANDARD"
  description = "The networking tier to be used for bastion instance (valid: PREMIUM or STANDARD)"
}

variable "bastion_instance_tags" {
  type        = list(string)
  description = "List of tags to attach to the bastion instance."
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

variable "operator_email" {
  type        = string
  description = "GCP service account e-mail address."
}

variable "scopes" {
  type        = list(string)
  default     = ["cloud-platform"]
  description = "List of service scopes."
}
