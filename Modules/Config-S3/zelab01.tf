##-----------------------------------------Create My S3 Bucket - without S3 encryption
###
resource "aws_s3_bucket" "my-bucket" {
  bucket = "clarencesela23"
  acl    = "private"

  tags = {
    Name        = "My Bucket"
    Environment = "Dev"
  }
}


##-----------------------------------------Configuration Recorder - The only one space where all our roles are defined
###
resource "aws_config_configuration_recorder" "ze-recorder" {
  name     = "ConfigSpace"
  role_arn = aws_iam_role.config-recorder-role.arn
}


##-----------------------------------------Config Rule - based on S3 Encryption
###
resource "aws_config_config_rule" "my-s3-rule" {
  name = "myS3Rule"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
}


##-----------------------------------------Remediation Action - based on the config rule
###
resource "aws_config_remediation_configuration" "self-remediation" {
  config_rule_name = aws_config_config_rule.my-s3-rule.name
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-EnableS3BucketEncryption"
  target_version   = "1"

#### Parameters
  parameter {
    name         = "AutomationAssumeRole"
    static_value = "arn:aws:iam::605705171400:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }
  parameter {
    name         = "SSEAlgorithm"
    static_value = "AES256"
  }
#### /Parameters

  automatic                  = true
  maximum_automatic_attempts = 10
  retry_attempt_seconds      = 60

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = 25
      error_percentage                     = 20
    }
  }
}


##-----------------------------------------Roles Used by the AWS Config
###
resource "aws_iam_role" "config-recorder-role" {
  name = "awsconfig-example"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}
