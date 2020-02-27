variable "region" {
    /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
    type = string
    description = "AWS region where the resources will be created."
}

variable "stack_name" {
    type    = string
    default = "Spectrum-Scale"
    description = "AWS stack name, will be used for tagging resources."
}

variable "cidr_block" {
    type        = string
    default     = "10.0.0.0/16"
    description = "The CIDR block for the VPC."
}

variable "availability_zones" {
    type = list(string)
    description = "List of AWS Availability Zones."
}

variable "total_compute_instances" {
    type = string
    default = 2
    description = "Number of EC2 instances to be launched for compute instances."
}

variable "compute_instance_type" {
    type        = string
    default     = "t2.medium"
    description = "Instance type to use for the compute instances."
}

variable "total_storage_instances" {
    type = string
    default = 2
    description = "Number of EC2 instances to be launched for storage instances."
}

variable "storage_instance_type" {
    type        = string
    default     = "t2.medium"
    description = "Instance type to use for the storage instances."
}

variable "ebs_enable_delete_on_termination" {
    type = bool
    default = false
    description = "Whether EBS volume to be deleted on instance termination."
}

variable "ebs_volumes_per_instance" {
    type = string
    default = 1
    description = "Number of disks to be attached to each storage instance."
}

variable "compute_ami_id" {
    type = string
    description = "AMI ID of provisioning compute instances."
}

variable "storage_ami_id" {
    type = string
    description = "AMI ID of provisioning storage instances"
}

variable "bastion_image_name" {
    type = string
    description = "Bastion AMI image name"
}

variable "bastion_instance_type" {
    type = string
    default = "t2.micro"
    description = "Instance type to use for the bastion instance."
}

variable "key_name" {
    type = string
    description = "Name for the AWS key pair"
}

variable "ebs_volume_iops" {
    type = string
    default = null
    description = "Provisioned IOPS (input/output operations per second) per volume."
}

variable "ebs_volume_size" {
    type    = string
    default = 500
    description = "EBS/Disk size in GiB"
}

variable "ebs_volume_type" {
    type    = string
    default = "gp2"
    description = "EBS volume types: io1, gp2, st1 and sc1."
}

variable "operator_email" {
    type = string
    description = "SNS notifications will be sent to provided email id."
}
