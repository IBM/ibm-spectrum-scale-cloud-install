/*
    Creates a Instance group.
*/

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "asg_name" {}
variable "launch_template_id" {}
variable "desired_instance_count" {}
variable "subnets" {}

resource "ibm_is_instance_group" "itself" {
  name              = var.asg_name
  instance_template = var.launch_template_id
  instance_count    = var.desired_instance_count
  subnets           = var.subnets
}

data "ibm_is_instances" "itself" {
  instance_group = ibm_is_instance_group.itself.id
  depends_on     = [ibm_is_instance_group.itself]
}

resource "ibm_is_floating_ip" "itself" {
  count      = var.desired_instance_count
  name       = format("fip-%s", data.ibm_is_instances.itself.instances[count.index].name)
  target     = data.ibm_is_instances.itself.instances[count.index].primary_network_interface[0].id
  depends_on = [ibm_is_instance_group.itself]
}

output "asg_id" {
  value = ibm_is_instance_group.itself.id
}

output "asg_crn" {
  value = ibm_is_instance_group.itself.crn
}

output "floating_ip_addresses" {
  value       = ibm_is_floating_ip.itself[*].address
  description = "List of floating IP addresses assigned to instances in the autoscaling group."
}
