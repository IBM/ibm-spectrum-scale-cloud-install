variable "vpc_id" {
  type        = string
  description = "The VPC id you want to use for building AMI."
}

variable "vpc_region" {
  type        = string
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_security_group_id" {
  type        = string
  description = "The security group id to assign to the instance, you must be sure the security group allows access to the ssh port."
}

variable "vpc_subnet_id" {
  type        = string
  description = "The subnet ID to use for the instance."
}

variable "ami_name" {
  type        = string
  description = "The name of the resulting AMI. To make this unique, timestamp will be appended."
}

variable "ami_description" {
  type        = string
  default     = "IBM Spectrum Scale AMI"
  description = "The description to set for the resulting AMI."
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use while building the AMI."
}

variable "source_image_reference" {
  type        = string
  description = "The source AMI id whose root volume will be copied and provisioned on the currently running instance."
}

variable "s3_spectrumscale_bucket" {
  type        = string
  description = "S3 bucket which contains IBM Spectrum Scale rpm(s)."
}

variable "scale_version" {
  type        = string
  description = "Spectrum Scale version."
}

variable "volume_size" {
  type        = string
  default     = "200"
  description = "The size of the volume, in GiB."
}

variable "volume_type" {
  type        = string
  default     = "gp2"
  description = "The volume type. gp2 & gp3 for General Purpose (SSD) volumes."
}
