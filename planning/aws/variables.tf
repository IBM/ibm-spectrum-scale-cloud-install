variable "user_name" {
  type        = string
  nullable    = false
  description = "An existing IAM username to which policy needs to be applied."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  default     = "us-east-1"
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}
