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
variable "total_client_cluster_instances" {}
variable "dest_ip" {}

resource "ibm_is_vpc_routing_table_route" "itself" {
  for_each = var.total_client_cluster_instances == 0 ? {} : {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      sequence_string = tostring(count_number)
      destination_ip  = element(var.dest_ip, idx)
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
}

output "route_details" {
  value      = resource.ibm_is_vpc_routing_table_route.itself
  depends_on = [resource.ibm_is_vpc_routing_table_route.itself]
}
