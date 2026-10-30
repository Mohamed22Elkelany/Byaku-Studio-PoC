output "policy_id" {
  value       = aws_cloudfront_cache_policy.this.id
  description = "The ID of the created policy"
}