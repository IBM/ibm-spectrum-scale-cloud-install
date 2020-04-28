/*
    Creates new AWS s3 bucket which will be used for storing
    terraform state file.
*/

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

resource "aws_s3_bucket" "create_bucket" {
  bucket        = var.bucket_name
  region        = var.region
  force_destroy = var.force_destroy

  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

output "bucket_id" {
  value = aws_s3_bucket.create_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.create_bucket.arn
}
