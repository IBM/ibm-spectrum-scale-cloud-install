/*
    Creates IBM Cloud routing table route for protocol nodes.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "total_vsis" {}
variable "vpc_id" {}
variable "routing_table" {}
variable "zone" {}
variable "action" {}
variable "next_hop" {}
variable "priority" {}
variable "turn_on" {}
variable "clone_complete" {}
variable "storage_cluster_create_complete" {}
variable "create_scale_cluster" {}
variable "scale_ces_enabled" {}
variable "dest_ip" {}
variable "storage_admin_ip" {}
variable "storage_private_key" {}

data "external" "get_ces_ips" {
  count = (tobool(var.turn_on) == true && tobool(var.scale_ces_enabled) == true && tobool(var.clone_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  program = ["bash", "-c", <<-EOT
    remote_command='/usr/lpp/mmfs/bin/mmces address list -Y | tail -n +2 | awk -F: '\''{print $7, $8}'\'' | sort -k2 | awk '\''{print $1}'\'''
    ces_ips=$(ssh -i ${var.storage_private_key} root@${var.storage_admin_ip} "$remote_command")
    ces_ips_json="{ \"ces_ips\": \"$ces_ips\" }"
    echo $ces_ips_json
  EOT
  ]
}

locals {
  ces_ips        = var.scale_ces_enabled == true && var.create_scale_cluster == true ? split(" ", data.external.get_ces_ips[0].result.ces_ips) : []
  destination_ip = var.scale_ces_enabled == true && var.create_scale_cluster == true ? local.ces_ips : var.dest_ip
}

resource "ibm_is_vpc_routing_table_route" "itself" {
  for_each = var.scale_ces_enabled == true && var.create_scale_cluster != true ? {} : {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      sequence_string = tostring(count_number)
      destination_ip  = element(local.destination_ip, idx)
      next_hop        = element(var.next_hop, idx)
      zone            = element(var.zone, idx)
    }
  }

  vpc           = var.vpc_id
  routing_table = var.routing_table
  zone          = each.value.zone
  name          = format("ces-%s", replace(each.value.destination_ip, ".", "-"))
  destination   = format("%s/32", each.value.destination_ip)
  action        = var.action
  next_hop      = each.value.next_hop
  priority      = var.priority
  depends_on    = [data.external.get_ces_ips]
}

output "route_details" {
  value      = resource.ibm_is_vpc_routing_table_route.itself
  depends_on = [resource.ibm_is_vpc_routing_table_route.itself]
}

output "ansible_ces_ip_result" {
  value      = local.ces_ips
  depends_on = [data.external.get_ces_ips]
}
