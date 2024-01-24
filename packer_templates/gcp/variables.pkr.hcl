variable "project_id" {
  type        = string
  description = "Project to be used to create the VM/image in your Google Cloud"
}

variable "credential_json_path" {
  type    = string
  default = "Service account credential json file path to be used"
}

variable "vpc_region" {
  type        = string
  description = "The region where GCP operations will take place. Examples are us-central1, us-east1 etc."
}

variable "vpc_zone" {
  type        = string
  description = "The VPC zone you want to use for building image."
}

variable "vpc_ref" {
  type        = string
  description = "The vpc network id or URL to use for the launched instance."
}

variable "vpc_subnet_id" {
  type        = string
  description = "The vpc subnetwork id or URL to use for the launched instance."
}

variable "resource_prefix" {
  type        = string
  description = "The name of the resulting image. To make this unique, timestamp will be appended."
}

variable "image_description" {
  type        = string
  default     = "IBM Spectrum Scale Image"
  description = "The description to set for the resulting image."
}

variable "instance_type" {
  type        = string
  description = "The GCP VM machine type to use while building the image."
}

variable "source_image_reference" {
  type        = string
  description = "The source image name used to create instance."
}

variable "source_image_family" {
  type        = string
  description = "The source image family whose root volume will be copied and provisioned on the currently running instance."
}

variable "artifact_id" {
  type        = string
  description = "GCS artifact registry name or id which contains IBM Spectrum Scale rpm(s)."
}

variable "volume_size" {
  type        = string
  default     = "200"
  description = "The size of the volume, in GiB."
}

variable "volume_type" {
  type        = string
  default     = "pd-ssd"
  description = "The volume type."
}

variable "ssh_username" {
  type        = string
  default     = null
  description = "The username to login/connect to SSH with."
}

variable "ssh_port" {
  type        = string
  default     = "22"
  description = "The port to connect to instance via SSH."
}

variable "ssh_bastion_host" {
  type        = string
  default     = null
  description = "A bastion host to use for the SSH connection."
}

variable "ssh_bastion_username" {
  type        = string
  default     = null
  description = "The username to connect to the bastion host."
}

variable "ssh_bastion_port" {
  type        = string
  default     = "22"
  description = "The port of the bastion host."
}

variable "ssh_bastion_private_key_file" {
  type        = string
  default     = null
  description = "Path to a private key file to use to authenticate with the bastion host."
}

variable "service_account_email" {
  type        = string
  description = "The service account to be used for launched instance."
}

variable "manifest_path" {
  type    = string
  default = ""
}

locals {
  manifest_path = var.manifest_path != "" ? var.manifest_path : path.root
}
