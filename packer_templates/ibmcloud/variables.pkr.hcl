variable "ibm_api_key" {
  type        = string
  description = "IBM Cloud API key."
}

variable "manifest_path" {
  type    = string
  default = ""
}

locals {
  manifest_path = var.manifest_path != "" ? var.manifest_path : path.root
}

variable "install_protocols" {
  type        = string
  default     = "*"
  description = "Flag to determine whether to install protocol packages or not."
}

variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "resource_group_name" {
  type        = string
  description = "The existing resource group name."
}

variable "vpc_subnet_id" {
  type        = string
  description = "The subnet ID to use for the instance."
}

variable "resource_prefix" {
  type        = string
  description = "The name of the resulting custom image. To make this unique, timestamp will be appended."
}

variable "vsi_profile" {
  type        = string
  default     = "bx2d-2x8"
  description = "The IBM Cloud vsi type to use while building the AMI."
}

variable "source_image_reference" {
  type        = string
  description = "The source image reference whose root volume will be copied and provisioned on the currently running instance."
}

variable "package_repository" {
  type        = string
  default     = null
  description = "COS bucket which contains IBM Spectrum Scale rpm(s)."
}

variable "private_key_file" {
  type        = string
  default     = "/root/.ssh/id_rsa"
  description = "The SSH private key file path, will be used to create a vpc ssh key pair."
}

variable "public_key_file" {
  type        = string
  default     = "/root/.ssh/id_rsa.pub"
  description = "The SSH public key file path, will be used to create a vpc ssh key pair."
}

variable "scale_version" {
  type        = string
  default     = null
  description = "IBM Storage Scale version."
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
