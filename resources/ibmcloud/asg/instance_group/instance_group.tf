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
variable "resource_group_id" {}

resource "ibm_is_instance_group" "itself" {
  name              = var.asg_name
  instance_template = var.launch_template_id
  instance_count    = var.desired_instance_count
  subnets           = var.subnets
  resource_group    = var.resource_group_id
}

data "ibm_is_instances" "itself" {
  instance_group = ibm_is_instance_group.itself.id
  depends_on     = [ibm_is_instance_group.itself]
}

resource "ibm_is_floating_ip" "itself" {
  count          = var.desired_instance_count
  name           = format("fip-%s", data.ibm_is_instances.itself.instances[count.index].name)
  zone           = data.ibm_is_instances.itself.instances[count.index].zone
  depends_on     = [ibm_is_instance_group.itself]
  resource_group = var.resource_group_id
}

# Bind each floating IP to the instance's primary virtual network interface (VNI-based attachment).
resource "ibm_is_virtual_network_interface_floating_ip" "itself" {
  count                      = var.desired_instance_count
  virtual_network_interface  = data.ibm_is_instances.itself.instances[count.index].primary_network_attachment[0].virtual_network_interface[0].id
  floating_ip                = ibm_is_floating_ip.itself[count.index].id
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
