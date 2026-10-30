output "repository_url" {
  description = "The URL of the ECR repository"
  value       = var.enabled ? aws_ecr_repository.this[0].repository_url : null
}

output "repository_arn" {
  description = "The ARN of the ECR repository"
  value       = var.enabled ? aws_ecr_repository.this[0].arn : null
}

output "repository_name" {
  description = "The name of the ECR repository"
  value       = var.enabled ? aws_ecr_repository.this[0].name : null
}
