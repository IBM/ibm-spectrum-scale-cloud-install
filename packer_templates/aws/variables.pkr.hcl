variable "image_description" {
  type        = string
  default     = "IBM Storeage Scale AMI"
  description = "The description to set for the resulting AMI."
}

variable "install_protocols" {
  type        = string
  default     = false
  description = "Flag to determine whether to install protocol packages or not."
}

variable "instance_type" {
  type        = string
  default     = null
  description = "The EC2 instance type to use while building the AMI."
}

variable "manifest_path" {
  type    = string
  default = ""
}

variable "package_repository" {
  type        = string
  default     = null
  description = "S3 bucket which contains IBM Spectrum Scale rpm(s)."
}

variable "resource_prefix" {
  type        = string
  description = "The name of the resulting AMI. To make this unique, timestamp will be appended."
}

variable "scale_version" {
  type        = string
  default     = null
  description = "IBM Storage Scale version."
}

variable "source_image_reference" {
  type        = string
  description = "The source AMI id whose root volume will be copied and provisioned on the currently running instance."
}

variable "ssh_bastion_host" {
  type        = string
  default     = ""
  description = "A bastion host to use for the SSH connection."
}

variable "ssh_bastion_port" {
  type        = string
  default     = "22"
  description = "The port of the bastion host."
}

variable "ssh_bastion_private_key_file" {
  type        = string
  default     = ""
  description = "Path to a private key file to use to authenticate with the bastion host."
}

variable "ssh_bastion_username" {
  type        = string
  default     = ""
  description = "The username to connect to the bastion host."
}

variable "ssh_port" {
  type        = string
  default     = "22"
  description = "The port to connect to instance via SSH."
}

variable "ssh_username" {
  type        = string
  description = "The username to connect to instance via SSH."
}

variable "volume_size" {
  type        = string
  default     = "200"
  description = "The size of the volume, in GiB."
}

variable "volume_type" {
  type        = string
  default     = "gp2"
  description = "The volume type. gp2 & gp3 for General Purpose (SSD) volumes."
}

variable "vpc_ref" {
  type        = string
  default     = null
  description = "The VPC id you want to use for building AMI."
}

variable "vpc_region" {
  type        = string
  default     = null
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

# If the security group id is not provided, a temporary security group with ssh access will be provisioned and cleaned up
variable "vpc_security_group_id" {
  type        = string
  default     = null
  description = "The security group id to assign to the instance, you must be sure the security group allows access to the ssh port."
}

variable "vpc_subnet_id" {
  type        = string
  default     = null
  description = "The subnet ID to use for the instance."
}

locals {
  manifest_path = var.manifest_path != "" ? var.manifest_path : path.root
}
