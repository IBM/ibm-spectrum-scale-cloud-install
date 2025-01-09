variable "credential_json_path" {
  type        = string
  nullable    = false
  description = "The path of a GCP service account key file in JSON format."
}

variable "project_id" {
  type        = string
  nullable    = false
  description = "GCP project ID to manage resources."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "Region where the resources will be created."
}

# {"vpc_name": "vpc_self_link"}
variable "storage_vpc_details" {
  type        = map(string)
  nullable    = false
  description = "Map of VPC details in where the storage cluster resides."
}

# {"vpc_name_1": "vpc_self_link_1", "vpc_name_2": "vpc_self_link_2", ...., "vpc_name_N": "vpc_self_link_N"}
variable "compute_vpc_details" {
  type        = map(string)
  nullable    = false
  description = "Map of VPC details(s) and their URI where the compute/client cluster(s) resides."
}
