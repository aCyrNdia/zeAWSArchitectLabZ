#----------------------------------------- Configure KMS encryption
###
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 30
}

#----------------------------------------- Configure an S3 Bucket
###
resource "aws_s3_bucket" "my-bucket" {
#### Create the Bucket
  bucket = "cyrillendia23"
  acl    = "private"

  tags = {
    Name = "cN23 Bucket"
  }

#### Prevent from Accidentally deletion
  versioning {
    enabled = true
    mfa_delete = true
  }

#### Add Policy
  lifecycle_rule {
    enabled = true

    tags = {
      rule      = "my-policy"
      autoclean = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

#### Enable SSE-KMS encryption - AWS Managed Key
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "AES256"
      }
    }
  }
}
