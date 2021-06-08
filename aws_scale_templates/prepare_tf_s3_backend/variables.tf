variable "vpc_region" {
  type        = string
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "bucket_name" {
  /* If omitted, Terraform will assign a random, unique name */
  type        = string
  description = "Name to be used for bucket (make sure it is unique)"
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Whether to allow a forceful destruction of this bucket"
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name, needs to be unique within a region"
}
