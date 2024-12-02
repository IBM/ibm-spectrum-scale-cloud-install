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

variable "vpc_template_inputs" {
  type = map(object({
    cluster_type                                    = string
    project_id                                      = string
    credential_json_path                            = string
    resource_prefix                                 = string
    vpc_availability_zones                          = list(string),
    vpc_cidr_block                                  = string,
    vpc_compute_cluster_private_subnets_cidr_blocks = list(string)
    vpc_description                                 = string
    vpc_public_subnets_cidr_blocks                  = list(string)
    vpc_region                                      = string
    vpc_routing_mode                                = string,
    vpc_storage_cluster_private_subnets_cidr_blocks = list(string)
  }))
  description = "Inputs required for VPC template (the vpc inputs defined here will be created)."
}

variable "custom_vpc" {
  type        = map(map(string))
  description = "Custom vpc input(s) which will be paired with either the created vpc(s) or among them self"
}
