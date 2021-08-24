variable "ibm_api_key" {
  type        = string
  description = "IBM Cloud API key."
}

variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "resource_group_id" {
  type        = string
  description = "The existing resource group id."
}

variable "vpc_subnet_id" {
  type        = string
  description = "The subnet ID to use for the instance."
}

variable "image_name" {
  type        = string
  description = "The name of the resulting custom image. To make this unique, timestamp will be appended."
}

variable "vsi_profile" {
  type        = string
  default     = "bx2d-2x8"
  description = "The IBM Cloud vsi type to use while building the AMI."
}

variable "source_image_name" {
  type        = string
  description = "The source image name whose root volume will be copied and provisioned on the currently running instance."
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
