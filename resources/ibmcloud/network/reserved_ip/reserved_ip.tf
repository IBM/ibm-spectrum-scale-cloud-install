# Reserves CES IP addresses in protocol subnets via ibm_is_subnet_reserved_ip.
# subnet_ids round-robins across AZ subnets — one entry per AZ is enough.
# ces_ip_addresses: empty = IBM Cloud auto-assigns; non-empty = reserves those exact IPs.

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "total_reserved_ips" {
  type        = number
  description = "Number of CES IPs to reserve (one per protocol node)."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Protocol subnet IDs (one per AZ). Nodes round-robin across them."
}

variable "name_prefix" {
  type        = string
  description = "Prefix for reserved IP names, e.g. '<resource_prefix>-protocol'."
}

variable "ces_ip_addresses" {
  type        = list(string)
  default     = []
  description = "Optional static IPs to reserve (one per protocol node). Empty = auto-assign. Must equal total_reserved_ips when set."

  validation {
    condition     = length(var.ces_ip_addresses) == 0 || length(var.ces_ip_addresses) == var.total_reserved_ips
    error_message = "ces_ip_addresses must be empty (auto-assign) or contain exactly total_reserved_ips entries."
  }
}

# One reserved IP per protocol node; round-robin across subnet_ids by AZ.
resource "ibm_is_subnet_reserved_ip" "ces" {
  for_each = {
    for idx in range(var.total_reserved_ips) : idx => {
      subnet  = element(var.subnet_ids, idx)
      name    = format("%s-ces-%d", var.name_prefix, idx + 1)
      address = length(var.ces_ip_addresses) > 0 ? var.ces_ip_addresses[idx] : null
    }
  }

  subnet  = each.value.subnet
  name    = each.value.name
  address = each.value.address
}

output "ces_ip_list" {
  description = "Ordered list of reserved CES IP addresses, one per protocol node."
  value       = [for idx in range(var.total_reserved_ips) : ibm_is_subnet_reserved_ip.ces[idx].address]
}

output "ces_name_ip_map" {
  description = "Map of reserved IP name to its allocated address."
  value       = { for k, v in ibm_is_subnet_reserved_ip.ces : v.name => v.address }
}
