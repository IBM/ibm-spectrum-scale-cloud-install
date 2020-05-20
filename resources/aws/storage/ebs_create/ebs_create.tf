/*
  Creates specified number of new AWS EBS Volumes per AZ.
*/

variable "total_ebs_volumes" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
variable "ebs_volume_size" {
  type = string
}
variable "ebs_volume_type" {
  type = string
}
variable "ebs_volume_iops" {
  type = string
}
variable "ebs_tags" {}

resource "aws_ebs_volume" "ebs_create" {
  count             = var.total_ebs_volumes
  availability_zone = element(var.availability_zones, count.index)
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  iops              = var.ebs_volume_type == "gp2" ? null : var.ebs_volume_iops

  tags = var.ebs_tags
}

output "ebs_volume_ids" {
  value = aws_ebs_volume.ebs_create.*.id
}

output "ebs_by_availability_zone" {
  # Result is a map from availability zone to instance ids, such as:
  #  {"us-east-1a": ["i-1234", "i-5678"]}
  value = {
    for ebs in aws_ebs_volume.ebs_create :
    ebs.availability_zone => ebs.id...
  }
}
