output "bucket_domain_name" {
  description = "The fully qualified domain name (FQDN) of the S3 bucket."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The region-specific domain name of the S3 bucket."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_id" {
  description = "The name or ID of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_region" {
  description = "The AWS region where the S3 bucket is located."
  value       = aws_s3_bucket.this.region
}
