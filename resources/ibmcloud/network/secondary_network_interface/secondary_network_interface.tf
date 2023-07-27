terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "vsi_name_prefix" {}
variable "total_vsis" {}
variable "instance_ids" {}
variable "vsi_subnet_id" {}
variable "security_group" {}
variable "dns_service_id" {}
variable "dns_zone_id" {}
variable "dns_domain" {}


resource "ibm_is_instance_network_interface" "secondary_interface" {
  for_each = {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      sequence_string = tostring(count_number)
      subnet_id       = element(var.vsi_subnet_id, idx)
      instance_id     = element(var.instance_ids, idx)
    }
  }
  name = format("%s-%s-eth1", var.vsi_name_prefix, each.value.sequence_string)
  instance = each.value.instance_id
  subnet = each.value.subnet_id
  security_groups = var.security_group
}

resource "ibm_dns_resource_record" "a_itself" {
  for_each = {
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      name       = element(tolist([for name_details in ibm_is_instance_network_interface.secondary_interface : name_details.name]), idx)
      network_ip = element(tolist([for ip_details in ibm_is_instance_network_interface.secondary_interface : ip_details.primary_ipv4_address]), idx)
    }
  }

  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = each.value.name
  rdata       = each.value.network_ip
  ttl         = 300
  depends_on  = [ibm_is_instance_network_interface.secondary_interface]
}

resource "ibm_dns_resource_record" "ptr_itself" {
  for_each = {
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      name       = element(tolist([for name_details in ibm_is_instance_network_interface.secondary_interface : name_details.name]), idx)
      network_ip = element(tolist([for ip_details in ibm_is_instance_network_interface.secondary_interface : ip_details.primary_ipv4_address]), idx)
    }
  }

  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = each.value.network_ip
  rdata       = format("%s.%s", each.value.name, var.dns_domain)
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.a_itself]
}

output "instance_private_ips" {
  value = try(toset([for instance_details in ibm_is_instance_network_interface.secondary_interface : instance_details.primary_ipv4_address]), [])
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "compute_sec_interface_ip_name_map" {
  value = try({ for instance_details in ibm_is_instance_network_interface.secondary_interface : instance_details.primary_ipv4_address => instance_details.name}, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "compute_sec_interface_ip_id_map" {
  value = try({ for ip_details in ibm_is_instance_network_interface.secondary_interface : ip_details.primary_ipv4_address => ip_details.id }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}