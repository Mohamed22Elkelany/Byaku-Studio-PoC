output "cloudwatch_log_group_name" {
  value       = aws_cloudwatch_log_group.this.name
  description = "Name of Cloudwatch log group"
}

output "cloudwatch_log_group_arn" {
  value       = aws_cloudwatch_log_group.this.arn
  description = "ARN of Cloudwatch log group"
}