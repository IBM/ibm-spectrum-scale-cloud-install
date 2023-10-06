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
variable "inventory_path" {}
variable "network_playbook_path" {}

resource "null_resource" "get_ces_ips" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${var.inventory_path} ${var.network_playbook_path}"
  }
  triggers = {
    build = timestamp()
  }
}

data "local_file" "read_ces_ips" {
  filename   = "/tmp/ces_ips.txt"
  depends_on = [resource.null_resource.get_ces_ips]
}

locals {
  ces_ips = jsondecode(data.local_file.read_ces_ips.content)
}

resource "ibm_is_vpc_routing_table_route" "itself" {
  for_each = {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      sequence_string = tostring(count_number)
      destination_ip  = element(local.ces_ips, idx)
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
  depends_on    = [resource.null_resource.get_ces_ips]
}

output "details" {
  value      = resource.ibm_is_vpc_routing_table_route.itself
  depends_on = [resource.ibm_is_vpc_routing_table_route.itself]
}

output "ansible_ces_ip_result" {
  value      = local.ces_ips
  depends_on = [data.local_file.read_ces_ips]
}
