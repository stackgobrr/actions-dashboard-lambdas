locals {
  # Resource naming prefix (project-environment)
  resource_prefix = "${var.project_name}-${var.environment}"
}

# S3 bucket for Lambda deployment artifacts
resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "${local.resource_prefix}-lambda-artifacts"
}

resource "aws_s3_bucket_versioning" "lambda_artifacts" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_artifacts" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}