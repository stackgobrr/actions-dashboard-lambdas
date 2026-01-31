# Lambda Artifact Bucket
output "lambda_artifacts_bucket" {
  description = "S3 bucket for Lambda deployment artifacts"
  value       = aws_s3_bucket.lambda_artifacts.id
}