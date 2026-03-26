/*
    Creates IBM Cloud Trusted Profile with policies (equivalent to AWS IAM Role + Instance Profile)
    This allows VSI instances to authenticate using compute resource identity without API keys.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "turn_on" {
  type        = bool
  default     = true
}

variable "profile_name_prefix" {
  type        = string
}

variable "profile_description" {
  type        = string
  default     = "Trusted profile for IBM Storage Scale cluster instances"
}

# Create Trusted Profile
resource "ibm_iam_trusted_profile" "cluster_profile" {
  count       = var.turn_on ? 1 : 0
  name        = "${var.profile_name_prefix}-cluster-profiles"
  description = var.profile_description
}

# IAM Policies for the profile
resource "ibm_iam_trusted_profile_policy" "vpc_permissions" {
  count      = var.turn_on ? 1 : 0
  profile_id = ibm_iam_trusted_profile.cluster_profile[0].id

  roles = ["Editor", "Operator", "Viewer"]

  resources {
    service = "is"
  }
}

output "trusted_profile_id" {
  value = var.turn_on ? ibm_iam_trusted_profile.cluster_profile[0].id : ""
}

output "trusted_profile_name" {
  value = var.turn_on ? ibm_iam_trusted_profile.cluster_profile[0].name : ""
}
