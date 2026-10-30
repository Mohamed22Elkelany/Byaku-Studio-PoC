output "secret_name" {
  value       = aws_secretsmanager_secret.this.name
  description = "Name of the Secrets Manager secret"
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.this.arn
  description = "ARN of the Secrets Manager secret"
}

output "secret_id" {
  value       = aws_secretsmanager_secret.this.id
  description = "ID of the Secrets Manager secret"
}

output "secret_version_id" {
  value       = try(aws_secretsmanager_secret_version.this[0].version_id, null)
  description = "Version ID of the current secret value"
}

output "secret_values" {
  value       = var.secret_values
  description = "Secret values stored in Secrets Manager"
  sensitive   = true
}

