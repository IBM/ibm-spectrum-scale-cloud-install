variable "region" {
  /*
    Keep it empty, it will be propagated via command line or via ".tfvars"
    or ".tfvars.json"
  */
  type        = string
  description = "AWS region where the resources will be created."
}

variable "bucket_name" {
  /*
    If omitted, Terraform will assign a random, unique name
  */
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
