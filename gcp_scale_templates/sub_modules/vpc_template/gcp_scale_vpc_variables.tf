variable "region" {
  type        = string
  description = "GCP region where the resources will be created."
}

variable "stack_name" {
  type        = string
  default     = "spectrum-scale"
  description = "GCP stack name, will be used for tagging resources."
}

variable "gcp_project_id" {
  type        = string
  default     = "spectrum-scale"
  description = "GCP project ID to manage resources."
}

variable "credentials_file_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "vpc_routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "Network-wide routing mode to use (valid: REGIONAL, GLOBAL)."
}

variable "vpc_description" {
  type        = string
  default     = "This VPC is used by IBM Spectrum Scale"
  description = "Description of VPC."
}

variable "public_subnet_cidr" {
  type        = string
  default     = "192.168.0.0/24"
  description = "Range of internal addresses."
}

variable "private_subnet_cidr" {
  type        = string
  default     = "192.168.1.0/24"
  description = "Range of internal addresses."
}
