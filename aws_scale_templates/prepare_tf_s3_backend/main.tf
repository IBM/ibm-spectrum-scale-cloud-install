/*
    1. Creates new AWS s3 bucket which will be used for storing
       terraform state file.

    2. Create a dynamodb table for locking the state file.
*/

resource "aws_s3_bucket" "itself" {
  bucket        = var.bucket_name
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
  tags = {
    Name = "IBM Spectrum Scale S3 remote terraform state store"
  }
}

resource "aws_dynamodb_table" "itself" {
  name           = var.dynamodb_table_name
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "IBM Spectrum Scale DynamoDB terraform state lock table"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.itself.id
}

output "bucket_arn" {
  value = aws_s3_bucket.itself.arn
}

output "dynamodb_table_name" {
  value      = var.dynamodb_table_name
  depends_on = [aws_dynamodb_table.itself]
}
