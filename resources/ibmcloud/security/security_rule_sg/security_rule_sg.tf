/*
    Creates protocol-specific security group rules for TCP, UDP, and ICMP
    using a source security group as the remote target.
*/

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "security_group_id" {
  description = "The security group ID to attach the rule to"
  type        = string
}

variable "sg_direction" {
  description = "Direction of traffic (inbound or outbound)"
  type        = string
}

variable "source_security_group_id" {
  description = "Source security group ID"
  type        = string
}

variable "rules" {
  description = "List of security rules to create"
  type = list(object({
    protocol  = string
    port_min  = optional(number)
    port_max  = optional(number)
    icmp_type = optional(number)
    icmp_code = optional(number)
  }))
  default = []
}

variable "enable_rule" {
  description = "Whether to enable these rules"
  type        = bool
  default     = true
}

locals {
  sg_id     = element(flatten([var.security_group_id]), 0)
  direction = element(flatten([var.sg_direction]), 0)
}

resource "ibm_is_security_group_rule" "itself" {
  count = var.enable_rule ? length(var.rules) : 0

  group     = local.sg_id
  direction = local.direction
  remote    = var.source_security_group_id
  protocol  = var.rules[count.index].protocol

  port_min = var.rules[count.index].protocol != "icmp" ? try(var.rules[count.index].port_min, null) : null
  port_max = var.rules[count.index].protocol != "icmp" ? try(var.rules[count.index].port_max, null) : null

  type = var.rules[count.index].protocol == "icmp" ? coalesce(try(var.rules[count.index].icmp_type, null), 8) : null
  code = var.rules[count.index].protocol == "icmp" ? coalesce(try(var.rules[count.index].icmp_code, null), 0) : null
}

output "security_rule_id" {
  description = "List of security rule IDs created"
  value       = ibm_is_security_group_rule.itself[*].id
}
