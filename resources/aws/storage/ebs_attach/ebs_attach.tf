/*
    Attaches spectified number of AWS EBS Volumes to EC2 instances per AZ.
*/

variable "total_volume_attachments" {
  type = string
}
variable "device_names" {
  type = list(string)
}
variable "ebs_volume_ids" {
  type = list(string)
}
variable "instance_ids" {
  type = list(string)
}


resource "aws_volume_attachment" "ebs_attach" {
  count       = var.total_volume_attachments
  device_name = element(var.device_names, count.index)
  volume_id   = element(var.ebs_volume_ids, count.index)
  instance_id = element(var.instance_ids, count.index)

  lifecycle {
    ignore_changes = [instance_id]
  }
}

output "instances_device_map" {
  value = {
    for instance in aws_volume_attachment.ebs_attach.*.instance_id :
    instance => var.device_names...
  }
}
