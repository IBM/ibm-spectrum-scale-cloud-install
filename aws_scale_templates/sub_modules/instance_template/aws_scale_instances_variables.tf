variable "region" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "AWS region where the resources will be created."
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC id."
}

variable "stack_name" {
  type        = string
  default     = "Spectrum-Scale"
  description = "AWS Stack name."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones."
}

variable "egress_access_cidr" {
  description = "List of egress CIDRs. Default : 0.0.0.0/0"
  type        = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "key_name" {
  type        = string
  description = "Name for the AWS key pair."
}

variable "root_volume_enable_delete_on_termination" {
  type        = bool
  default     = true
  description = "Whether the root volume should be destroyed on instance termination."
}

variable "compute_ami_id" {
  type        = string
  description = "AMI ID of provisioning compute instances."
}

variable "compute_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to use for the compute instance."
}

variable "total_compute_instances" {
  type        = string
  default     = "2"
  description = "Number of EC2 instances to be launched for compute instances."
}

variable "compute_root_volume_size" {
  type        = string
  default     = 100
  description = "Size of root volume in gibibytes (GiB)."
}

variable "compute_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: io1, gp2, st1 and sc1."
}

variable "storage_ami_id" {
  type        = string
  description = "AMI ID of provisioning storage instances."
}

variable "storage_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to use for the storage instance."
}

variable "total_storage_instances" {
  type        = string
  default     = "2"
  description = "Number of EC2 instances to be launched for storage instances."
}

variable "storage_root_volume_size" {
  type        = string
  default     = 100
  description = "Size of root volume in gibibytes (GiB)."
}

variable "storage_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: io1, gp2, st1 and sc1."
}

variable "ebs_volumes_per_instance" {
  type        = string
  default     = 1
  description = "Number of disks to be attached to each storage instance."
}

variable "ebs_enable_delete_on_termination" {
  type        = bool
  default     = false
  description = "Whether EBS volume to be deleted on instance termination."
}

variable "enable_instance_termination_protection" {
  type        = bool
  default     = false
  description = "If true, enables EC2 Instance Termination Protection."
}

variable "ebs_volume_device_names" {
  type = list(string)
  default = ["/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj",
    "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo",
  "/dev/xvdp", ]
  description = "Name of the block device to mount on the instance"
}

variable "ebs_volume_iops" {
  type        = string
  default     = null
  description = "Provisioned IOPS (input/output operations per second) per volume."
}

variable "ebs_volume_size" {
  type        = string
  default     = 500
  description = "EBS/Disk size in GiB"
}

variable "ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: io1, gp2, st1 and sc1."
}

variable "bastion_sec_group_id" {
  type        = string
  description = "AWS Bastion security group id."
}

variable "deploy_container_sec_group_id" {
  type        = string
  default     = null
  description = "Deployment container (ECS-FARGATE) security group id. Default: null"
}

variable "private_instance_subnet_ids" {
  type        = list(string)
  description = "List of instances private security subnet ids."
}

variable "operator_email" {
  type        = string
  description = "SNS notifications will be sent to provided email id."
}
