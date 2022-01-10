#----------------------------------------- Configure an S3 Bucket
###
resource "aws_s3_bucket" "my-bucket" {
#### Create the Bucket
  bucket = "cyrillendia23"
  acl    = "private"

  tags = {
    Name = "CN23 Bucket"
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
}

#----------------------------------------- Configure KMS encryption
###
