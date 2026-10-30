output "distribution_id" {
  description = "The unique identifier of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "The Amazon Resource Name (ARN) of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "status" {
  description = "The current status of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.status
}

output "last_modified_time" {
  description = "The timestamp when the CloudFront distribution was last modified."
  value       = aws_cloudfront_distribution.this.last_modified_time
}

output "aliases" {
  description = "The list of CNAMEs (aliases) associated with the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.aliases
}

output "web_acl_id" {
  description = "The ID of the associated AWS WAF Web ACL, if any."
  value       = aws_cloudfront_distribution.this.web_acl_id
}

output "viewer_certificate" {
  description = "Information about the SSL/TLS certificate associated with the distribution."
  value       = aws_cloudfront_distribution.this.viewer_certificate
}

output "distribution_configuration" {
  description = "A comprehensive output containing the full configuration of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this
}