/*
    Creates protocol-specific security group rules for TCP, UDP, and ICMP.
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

variable "remote_ip_addr" {
  description = "Remote IP address, CIDR block, or list of them"
  type        = any
}

variable "rules" {
  description = "List of security rules to create"
  type = list(object({
    protocol  = string           # tcp, udp, or icmp
    port_min  = optional(number) # Minimum port (for TCP/UDP)
    port_max  = optional(number) # Maximum port (for TCP/UDP)
    icmp_type = optional(number) # ICMP type (for ICMP)
    icmp_code = optional(number) # ICMP code (for ICMP)
  }))
  default = []
}

variable "enable_rule" {
  description = "Whether to enable these rules"
  type        = bool
  default     = true
}

locals {
  # Normalize inputs
  sg_id     = element(flatten([var.security_group_id]), 0)
  direction = element(flatten([var.sg_direction]), 0)

  # Normalize remote_ip_addr to always be a list
  remote_list = flatten([var.remote_ip_addr])

  # Create a flattened list of (rule, remote) combinations
  # This allows multiple CIDRs to be specified, creating a separate rule for each
  rule_remote_combinations = var.enable_rule ? flatten([
    for rule_idx, rule in var.rules : [
      for remote_idx, remote in local.remote_list : {
        key       = "${rule.protocol}-${rule_idx}-remote-${remote_idx}"
        protocol  = rule.protocol
        port_min  = rule.port_min
        port_max  = rule.port_max
        icmp_type = rule.icmp_type
        icmp_code = rule.icmp_code
        remote    = remote
      }
    ]
  ]) : []
}

resource "ibm_is_security_group_rule" "itself" {
  for_each = { for combo in local.rule_remote_combinations : combo.key => combo }

  group     = local.sg_id
  direction = local.direction
  remote    = each.value.remote
  protocol  = each.value.protocol

  # TCP/UDP ports
  port_min = each.value.protocol != "icmp" ? each.value.port_min : null
  port_max = each.value.protocol != "icmp" ? each.value.port_max : null

  # ICMP type/code
  type = each.value.protocol == "icmp" ? coalesce(each.value.icmp_type, 8) : null
  code = each.value.protocol == "icmp" ? coalesce(each.value.icmp_code, 0) : null
}

output "security_rule_id" {
  description = "List of security rule IDs created"
  value       = [for rule in ibm_is_security_group_rule.itself : rule.id]
}
