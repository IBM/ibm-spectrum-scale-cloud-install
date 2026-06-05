/*
    Creates IBM Cloud SSH key resource for instance access.
*/

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "create_ssh_key" {
  type        = bool
  description = "Flag to enable or disable SSH key creation."
}

variable "ssh_key_name" {
  type        = string
  description = "Name for the SSH key resource."
}

variable "public_key" {
  type        = string
  description = "SSH public key content."
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud resource group ID."
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "List of tags to attach to the SSH key resource."
}

resource "ibm_is_ssh_key" "itself" {
  count          = var.create_ssh_key ? 1 : 0
  name           = var.ssh_key_name
  public_key     = trimspace(var.public_key)
  resource_group = var.resource_group_id
  tags           = var.tags
}

output "ssh_key_id" {
  value       = try(ibm_is_ssh_key.itself[0].id, null)
  description = "ID of the created SSH key resource."
}

output "ssh_key_fingerprint" {
  value       = try(ibm_is_ssh_key.itself[0].fingerprint, null)
  description = "Fingerprint of the SSH key."
}
